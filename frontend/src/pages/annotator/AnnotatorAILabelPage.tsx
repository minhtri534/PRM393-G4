import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import DashboardLayout from "../../layouts/DashboardLayout";
import { Card } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { Input } from "../../components/ui/Input";
import { annotatorService } from "../../services/annotatorService";
import type { 
  AnnotatorTaskSummary, 
  LabelResponse, 
  UpsertTaskAnnotationsPayload,
  AnnotatorReviewFeedbackResponse,
  AiAssistSuggestResponse
} from "../../types/annotator";
import {
  Bot,
  ChevronLeft,
  ChevronRight,
  Loader2,
  Pencil,
  Save,
  Send,
  Trash,
  ZoomIn,
  ZoomOut,
  AlertCircle,
  MessageSquare,
  Check,
  X,
} from "lucide-react";

interface Box {
  id?: string;
  x: number;
  y: number;
  width: number;
  height: number;
  labelId: string;
  isAiSuggestion?: boolean;
  predictionId?: string;
  confidence?: number;
}

interface ToastMessage {
  id: number;
  type: "success" | "error" | "info";
  text: string;
}

const CANVAS_BASE_WIDTH = 800;

const FALLBACK_IMAGE =
  "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

export default function AnnotatorAILabelPage() {
  const { id: taskIdFromUrl } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const containerRef = useRef<HTMLDivElement | null>(null);

  const [task, setTask] = useState<AnnotatorTaskSummary | null>(null);
  const [labels, setLabels] = useState<LabelResponse[]>([]);
  const [guideline, setGuideline] = useState<string>("");
  const [reviewFeedback, setReviewFeedback] = useState<AnnotatorReviewFeedbackResponse | null>(null);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [aiLoading, setAiLoading] = useState(false);

  const [zoom, setZoom] = useState(1);
  const [drawMode, setDrawMode] = useState(false);
  const [drawing, setDrawing] = useState(false);
  const [startPoint, setStartPoint] = useState<{ x: number; y: number } | null>(null);
  const [previewBox, setPreviewBox] = useState<Box | null>(null);

  const [boxes, setBoxes] = useState<Box[]>([]);
  const [selectedLabelId, setSelectedLabelId] = useState<string>("");
  const [secureImageUrl, setSecureImageUrl] = useState<string>("");
  const [imageNaturalSize, setImageNaturalSize] = useState<{ width: number; height: number } | null>(null);
  const [reworkComment, setReworkComment] = useState("");
  const [aiOnlySelectedLabel, setAiOnlySelectedLabel] = useState(false);
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const currentTaskId = task?.id || "";
  const scaleX = imageNaturalSize ? CANVAS_BASE_WIDTH / imageNaturalSize.width : 1;
  const scaleY = imageNaturalSize ? (CANVAS_BASE_WIDTH * imageNaturalSize.height) / imageNaturalSize.width / imageNaturalSize.height : 1;

  const showToast = (type: ToastMessage["type"], text: string) => {
    const id = Date.now() + Math.floor(Math.random() * 1000);
    setToasts((prev) => [...prev, { id, type, text }]);
    window.setTimeout(() => {
      setToasts((prev) => prev.filter((toast) => toast.id !== id));
    }, 3800);
  };

  const loadTaskContext = async (taskId: string) => {
    try {
      const taskRes = await annotatorService.getMyTasks();
      let currentTask: AnnotatorTaskSummary | null = null;

      if (taskRes.isSuccess) {
        currentTask = (taskRes.data || []).find((x) => x.id === taskId) || null;
        setTask(currentTask);
      }

      // Only fetch feedback if the task status indicates it might have one (Rework or Completed)
      const needsFeedback = currentTask && ["Returned", "Rejected", "Rework", "Completed"].includes(currentTask.status);
      const feedbackPromise = needsFeedback 
        ? annotatorService.getReviewFeedback(taskId).catch(() => ({ isSuccess: false, data: null }))
        : Promise.resolve({ isSuccess: false, data: null });

      const [labelsRes, guidelineRes, annRes, feedbackRes] = await Promise.all([
        annotatorService.getLabels(taskId),
        annotatorService.getGuideline(taskId),
        annotatorService.getAnnotations(taskId),
        feedbackPromise,
      ]);

      if (labelsRes.isSuccess) {
        const labelData = labelsRes.data || [];
        setLabels(labelData);
        if (labelData.length > 0) {
          setSelectedLabelId(labelData[0].id);
        }
      }

      if (guidelineRes.isSuccess) {
        setGuideline(guidelineRes.data?.guideline || "");
      }

      if (annRes.isSuccess) {
        const parsed = (annRes.data || [])
          .map((ann) => {
            try {
              let geo: any = ann.geometryData;
              // Handle potential double-encoding from backend/previous saves
              if (typeof geo === 'string') {
                geo = JSON.parse(geo);
                // If it's still a string after one parse, parse it again
                if (typeof geo === 'string') {
                  geo = JSON.parse(geo);
                }
              }
              
              if (
                !geo ||
                typeof geo.x !== "number" ||
                typeof geo.y !== "number" ||
                typeof geo.width !== "number" ||
                typeof geo.height !== "number"
              ) {
                return null;
              }

              return {
                id: ann.id,
                x: geo.x,
                y: geo.y,
                width: geo.width,
                height: geo.height,
                labelId: ann.labelId,
              } as Box;
            } catch (e) {
              console.error("Error parsing annotation geometry:", e, ann.geometryData);
              return null;
            }
          })
          .filter((x): x is Box => x !== null);

        setBoxes(parsed);
      }

      if (feedbackRes.isSuccess && feedbackRes.data) {
        const data = Array.isArray(feedbackRes.data) ? feedbackRes.data[0] : feedbackRes.data;
        setReviewFeedback(data);
      }
    } catch (err) {
      console.error("Error loading task data:", err);
    }
  };

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      try {
        let activeId = taskIdFromUrl || "";

        if (!activeId) {
          const taskRes = await annotatorService.getMyTasks();
          if (taskRes.isSuccess) {
            const preferred = (taskRes.data || []).find((x) => x.status !== "Submitted") || taskRes.data?.[0];
            if (preferred) {
              activeId = preferred.id;
              navigate(`/annotator/ai-label/${preferred.id}`, { replace: true });
            }
          }
        }

        if (!activeId) {
          setTask(null);
          return;
        }

        await annotatorService.startTask(activeId);
        await loadTaskContext(activeId);
      } finally {
        setLoading(false);
      }
    };

    init();
  }, [taskIdFromUrl, navigate]);

  useEffect(() => {
    let objectUrl = "";
    const loadImage = async () => {
      if (!currentTaskId) return;
      try {
        const blob = await annotatorService.getImageSecure(currentTaskId);
        objectUrl = URL.createObjectURL(blob);
        setSecureImageUrl(objectUrl);
      } catch {
        setSecureImageUrl(FALLBACK_IMAGE);
      }
    };

    loadImage();
    return () => {
      if (objectUrl) {
        URL.revokeObjectURL(objectUrl);
      }
    };
  }, [currentTaskId]);

  const savePayload: UpsertTaskAnnotationsPayload = useMemo(
    () => ({
      objects: boxes.map((b) => ({
        labelId: b.labelId,
        geometryData: JSON.stringify({ 
          type: "bbox",
          x: Math.round(b.x),
          y: Math.round(b.y),
          width: Math.round(b.width),
          height: Math.round(b.height),
        }),
      })),
    }),
    [boxes]
  );

  const handleSave = async (isSubmit: boolean) => {
    if (!currentTaskId) return;
    if (isSubmit && boxes.length === 0) {
      showToast("error", "Please label at least one object before submitting.");
      return;
    }

    setSaving(true);
    try {
      if (isSubmit && reviewFeedback && reworkComment) {
        await annotatorService.addCommentToReviewer(reviewFeedback.id, reworkComment);
      }

      const res = isSubmit
        ? await annotatorService.submit(currentTaskId, savePayload)
        : await annotatorService.saveDraft(currentTaskId, savePayload);

      if (res.isSuccess) {
        showToast("success", isSubmit ? "Submission successful!" : "Draft saved.");
        if (isSubmit) navigate("/annotator/tasks");
      } else {
        showToast("error", res.message || "Error saving data.");
      }
    } finally {
      setSaving(false);
    }
  };

  const handleAiSuggest = async () => {
    if (!currentTaskId) return;

    setAiLoading(true);
    try {
      const labelFilter = aiOnlySelectedLabel ? selectedLabelId : undefined;
      const res = await annotatorService.suggestAi(currentTaskId, false, labelFilter);
      if (!res.isSuccess || !res.data) {
        const details = (res.errors || []).join("; ");
        showToast("error", details ? `${res.message}. ${details}` : (res.message || "AI found no suggestions or AI service is disabled."));
        return;
      }

      const aiBoxes = res.data.objects
        .map((obj) => {
          try {
            let geo: any = obj.geometryData;
            if (typeof geo === 'string') {
              geo = JSON.parse(geo);
              if (typeof geo === 'string') {
                geo = JSON.parse(geo);
              }
            }

            if (
              !geo ||
              typeof geo.x !== "number" ||
              typeof geo.y !== "number" ||
              typeof geo.width !== "number" ||
              typeof geo.height !== "number"
            ) {
              return null;
            }

            return {
              x: geo.x,
              y: geo.y,
              width: geo.width,
              height: geo.height,
              labelId: obj.labelId,
              isAiSuggestion: true,
              predictionId: res.data.runId, // Using runId as predictionId for now
              confidence: obj.confidence,
            } as Box;
          } catch {
            return null;
          }
        })
        .filter((x): x is Box => x !== null);

      if (aiBoxes.length > 0) {
        setBoxes((prev) => [...prev, ...aiBoxes]);
        showToast(
          "success",
          `AI detected ${res.data.objects.length} object(s), mapped ${aiBoxes.length} object(s) into current project labels.\n` +
          `You can accept or reject each suggestion.`
        );
      } else {
        const projectLabelSummary = labels.length > 0
          ? labels.map((x) => `${x.name}:${x.yoloClassId}`).join(", ")
          : "(no labels in project)";

        showToast(
          "info",
          `AI responded successfully but no suggestions were added.\n` +
          `Possible causes:\n` +
          `1) The image has no detectable objects.\n` +
          `2) Project labels do not match model class ids.\n` +
          `Current labels => ${projectLabelSummary}\n` +
          `Tip: person=0, car=2, cat=15, dog=16 (COCO yolov8n).`
        );
      }
    } catch (error: any) {
      const backendMessage = error?.response?.data?.message;
      const backendErrors = error?.response?.data?.errors;
      const detail = Array.isArray(backendErrors) ? backendErrors.join("; ") : "";

      showToast(
        "error",
        `AI Suggest request failed.\n` +
        `${backendMessage || "Cannot connect to AI service or backend."}\n` +
        `${detail}`.trim()
      );
    } finally {
      setAiLoading(false);
    }
  };

  const handleAcceptAi = async (boxIndex: number) => {
    const box = boxes[boxIndex];
    if (!box.predictionId) return;

    try {
      const res = await annotatorService.acceptAiSuggestion(currentTaskId, box.predictionId);
      if (res.isSuccess) {
        setBoxes(prev => prev.map((b, i) => i === boxIndex ? { ...b, isAiSuggestion: false } : b));
      }
    } catch (err) {
      console.error("Error accepting AI:", err);
    }
  };

  const handleRejectAi = async (boxIndex: number) => {
    const box = boxes[boxIndex];
    if (!box.predictionId) {
      setBoxes(prev => prev.filter((_, i) => i !== boxIndex));
      return;
    }

    const reason = prompt("Lý do từ chối gợi ý này?");
    if (reason === null) return;

    try {
      const res = await annotatorService.rejectAiSuggestion(currentTaskId, box.predictionId, reason || "Không chính xác");
      if (res.isSuccess) {
        setBoxes(prev => prev.filter((_, i) => i !== boxIndex));
      }
    } catch (err) {
      console.error("Error rejecting AI:", err);
    }
  };

  const getMousePosition = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!containerRef.current) return { x: 0, y: 0 };
    const rect = containerRef.current.getBoundingClientRect();

    const displayX = (e.clientX - rect.left) / zoom;
    const displayY = (e.clientY - rect.top) / zoom;

    return {
      x: displayX / scaleX,
      y: displayY / scaleY,
    };
  };

  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!drawMode) return;
    setStartPoint(getMousePosition(e));
    setDrawing(true);
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!drawing || !startPoint) return;
    const p = getMousePosition(e);
    setPreviewBox({
      x: Math.min(startPoint.x, p.x),
      y: Math.min(startPoint.y, p.y),
      width: Math.abs(startPoint.x - p.x),
      height: Math.abs(startPoint.y - p.y),
      labelId: selectedLabelId,
    });
  };

  const handleMouseUp = () => {
    if (!drawing || !previewBox || previewBox.width < 5 || previewBox.height < 5 || !selectedLabelId) {
      setDrawing(false);
      setPreviewBox(null);
      return;
    }

    setBoxes((prev) => [...prev, { ...previewBox, labelId: selectedLabelId }]);
    setDrawing(false);
    setPreviewBox(null);
    setStartPoint(null);
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="h-full flex flex-col items-center justify-center text-gray-500 gap-3">
          <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
          <p className="font-medium">Setting up workspace...</p>
        </div>
      </DashboardLayout>
    );
  }

  if (!task) {
    return (
      <DashboardLayout>
        <Card className="max-w-4xl mx-auto p-10 text-center text-gray-600">No task to label.</Card>
      </DashboardLayout>
    );
  }

  const isRework = task.status === "Returned" || task.status === "Rejected" || task.status === "Rework";
  const isCompleted = task.status === "Completed";
  const isReadOnly = isCompleted || task.status === "Submitted";

  return (
    <DashboardLayout>
      <div className="fixed top-5 right-5 z-[80] flex w-[360px] max-w-[calc(100vw-2rem)] flex-col gap-2">
        {toasts.map((toast) => (
          <div
            key={toast.id}
            className={`rounded-lg border px-3 py-2 text-sm shadow-lg whitespace-pre-line ${
              toast.type === "success"
                ? "bg-emerald-50 border-emerald-200 text-emerald-800"
                : toast.type === "error"
                  ? "bg-red-50 border-red-200 text-red-800"
                  : "bg-blue-50 border-blue-200 text-blue-800"
            }`}
          >
            {toast.text}
          </div>
        ))}
      </div>
      <div className="h-[calc(100vh-120px)] flex flex-col gap-4">
        {/* Review Feedback Banner */}
        {(isRework || isCompleted) && reviewFeedback && (
          <div className={`${
            isCompleted ? "bg-green-50 border-green-200" : "bg-amber-50 border-amber-200"
          } border p-3 rounded-xl flex items-start gap-3 shadow-sm`}>
              <AlertCircle className={`${isCompleted ? "text-green-600" : "text-amber-600"} h-5 w-5 mt-0.5 shrink-0`} />
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <span className={`font-bold ${isCompleted ? "text-green-900" : "text-amber-900"} text-sm`}>
                  {isCompleted ? "Reviewer Approved" : "Revision request from Reviewer"}
                </span>
                <span className={`${isCompleted ? "bg-green-200 text-green-800" : "bg-amber-200 text-amber-800"} text-[10px] px-2 py-0.5 rounded font-bold`}>
                  Điểm: {reviewFeedback.score}/100
                </span>
              </div>
              <p className={`text-sm ${isCompleted ? "text-green-800" : "text-amber-800"} italic mt-1`}>
                "{reviewFeedback.comment || (isCompleted ? "Good job!" : "Please check accuracy.")}"
              </p>
              <div className="flex gap-2 mt-2">
                {(reviewFeedback.categories || []).map(c => (
                  <span key={c.errorTypeId} className={`bg-white/60 border ${
                    isCompleted ? "border-green-100 text-green-700" : "border-amber-100 text-amber-700"
                  } text-[10px] px-2 py-0.5 rounded`}>
                    {c.errorName}
                  </span>
                ))}
              </div>
            </div>
            {!isCompleted && (
              <div className="flex flex-col gap-2 min-w-[200px]">
                  <Input 
                  size={3}
                  placeholder="Feedback for Reviewer..." 
                  value={reworkComment} 
                  onChange={(e) => setReworkComment(e.target.value)}
                  className="bg-white/80 text-xs h-8"
                />
              </div>
            )}
          </div>
        )}

        {/* Toolbar Top */}
        <div className="flex items-center justify-between bg-white p-3 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm" onClick={() => navigate("/annotator/tasks")}> 
              <ChevronLeft size={18} className="mr-1" /> Back
            </Button>
            <div className="h-6 w-[1px] bg-gray-200" />
            <h2 className="font-bold text-gray-900">Task #{currentTaskId.slice(-6)}</h2>
            <div className={`px-2 py-1 rounded text-xs font-bold uppercase ${
              isRework ? "bg-red-50 text-red-600" : "bg-blue-50 text-blue-600"
            }`}>
              {task?.status === "InProgress" ? "In Progress" : 
               task?.status === "Returned" ? "Needs Revision" : task?.status}
            </div>
          </div>

          <div className="flex items-center gap-2">
            <div className="flex bg-gray-100 p-1 rounded-lg mr-4">
              <Button
                variant={!drawMode ? "primary" : "ghost"}
                size="sm"
                onClick={() => setDrawMode(false)}
                className="h-8 px-3"
              >
                View
              </Button>
              <Button
                variant={drawMode ? "primary" : "ghost"}
                size="sm"
                onClick={() => !isReadOnly && setDrawMode(true)}
                disabled={isReadOnly}
                className="h-8 px-3"
                title={isReadOnly ? "Task is read-only" : ""}
              >
                <Pencil size={14} className="mr-1" /> Draw
              </Button>
            </div>

            <Button variant="outline" size="sm" onClick={() => setZoom((z) => Math.max(0.5, z - 0.2))}>
              <ZoomOut size={16} />
            </Button>
            <span className="text-xs font-mono w-12 text-center">{Math.round(zoom * 100)}%</span>
            <Button variant="outline" size="sm" onClick={() => setZoom((z) => Math.min(3, z + 0.2))}>
              <ZoomIn size={16} />
            </Button>

            <div className="h-6 w-[1px] bg-gray-200 mx-2" />

            <Button
              variant="secondary"
              size="sm"
              onClick={handleAiSuggest}
              disabled={aiLoading || isReadOnly}
              className="bg-emerald-50 text-emerald-700 border-emerald-100 hover:bg-emerald-100"
            >
              {aiLoading ? <Loader2 size={16} className="animate-spin" /> : <Bot size={16} className="mr-1" />}
              AI Suggestions
            </Button>
            <Button
              variant={aiOnlySelectedLabel ? "primary" : "outline"}
              size="sm"
              onClick={() => setAiOnlySelectedLabel((v) => !v)}
              disabled={isReadOnly}
              title="When enabled, AI only returns suggestions for the currently selected label"
            >
              {aiOnlySelectedLabel ? "Selected Label Only: ON" : "Selected Label Only: OFF"}
            </Button>
          </div>

          <div className="flex items-center gap-2">
            {!isReadOnly && (
              <>
                <Button variant="outline" size="sm" onClick={() => handleSave(false)} disabled={saving}>
                  <Save size={16} className="mr-1" /> Save Draft
                </Button>
                <Button variant="primary" size="sm" onClick={() => handleSave(true)} disabled={saving} className="bg-blue-600 hover:bg-blue-700">
                  <Send size={16} className="mr-1" /> {isRework ? "Resubmit" : "Submit"}
                </Button>
              </>
            )}
            {isReadOnly && (
              <div className="bg-green-100 text-green-700 px-4 py-2 rounded-lg text-sm font-bold flex items-center gap-2">
                <Check size={18} />
                Task {task?.status}
              </div>
            )}
          </div>
        </div>

        <div className="flex-1 flex gap-4 overflow-hidden">
          {/* Main Canvas Area */}
          <Card className="flex-1 bg-gray-900 relative overflow-auto custom-scrollbar flex items-center justify-center p-8">
              <div
                ref={containerRef}
                className="relative shadow-2xl transition-transform duration-200"
                style={{
                  width: "fit-content",
                  height: "fit-content",
                  cursor: isReadOnly ? "default" : (drawMode ? "crosshair" : "default"),
                }}
                onMouseDown={(e) => !isReadOnly && handleMouseDown(e)}
                onMouseMove={(e) => !isReadOnly && handleMouseMove(e)}
                onMouseUp={() => !isReadOnly && handleMouseUp()}
              >
              <img
                src={secureImageUrl}
                    alt="Labeled Data"
                draggable={false}
                onLoad={(e) => {
                  const target = e.currentTarget;
                  if (target.naturalWidth > 0 && target.naturalHeight > 0) {
                    setImageNaturalSize({ width: target.naturalWidth, height: target.naturalHeight });
                  }
                }}
                style={{
                  width: CANVAS_BASE_WIDTH * zoom,
                  height: "auto",
                  display: "block",
                  userSelect: "none",
                }}
              />

              {/* Existing Boxes */}
              {boxes.map((box, i) => (
                <div
                  key={`${box.labelId}-${i}`}
                  className={`absolute border-2 group cursor-pointer transition-all ${
                    box.isAiSuggestion 
                      ? "border-amber-400 bg-amber-400/20" 
                      : "border-emerald-400 bg-emerald-400/20"
                  }`}
                  style={{
                    left: box.x * scaleX * zoom,
                    top: box.y * scaleY * zoom,
                    width: box.width * scaleX * zoom,
                    height: box.height * scaleY * zoom,
                  }}
                  onClick={(e) => {
                    e.stopPropagation();
                    if (!box.isAiSuggestion && !isReadOnly) {
                      setBoxes((prev) => prev.filter((_, idx) => idx !== i));
                    }
                  }}
                >
                  <div className={`absolute -top-6 left-0 text-white text-[10px] px-1 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap flex items-center gap-1 ${
                    box.isAiSuggestion ? "bg-amber-500" : "bg-emerald-500"
                  }`}>
                    {box.isAiSuggestion && <Bot size={10} />}
                    {labels.find(l => l.id === box.labelId)?.name || "Unknown"}
                    {box.confidence && ` (${Math.round(box.confidence * 100)}%)`}
                  </div>

                  {/* AI Suggestion Actions */}
                  {box.isAiSuggestion && (
                    <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button 
                        onClick={(e) => { e.stopPropagation(); handleAcceptAi(i); }}
                        className="p-1 bg-emerald-500 text-white rounded hover:bg-emerald-600 shadow-lg"
                          title="Accept"
                      >
                        <Check size={12} />
                      </button>
                      <button 
                        onClick={(e) => { e.stopPropagation(); handleRejectAi(i); }}
                        className="p-1 bg-red-500 text-white rounded hover:bg-red-600 shadow-lg"
                        title="Reject"
                      >
                        <X size={12} />
                      </button>
                    </div>
                  )}
                </div>
              ))}

              {/* Preview Box while drawing */}
              {previewBox && (
                <div
                  className="absolute border-2 border-blue-400 bg-blue-400/20"
                  style={{
                    left: previewBox.x * scaleX * zoom,
                    top: previewBox.y * scaleY * zoom,
                    width: previewBox.width * scaleX * zoom,
                    height: previewBox.height * scaleY * zoom,
                  }}
                />
              )}
            </div>
          </Card>

          {/* Sidebar Tools */}
          <div className="w-72 flex flex-col gap-4">
            {/* Label Selection */}
            <Card className="p-4 flex flex-col gap-3">
              <h3 className="font-bold text-sm text-gray-700 uppercase tracking-wider">Chọn nhãn</h3>
              <div className="flex flex-col gap-2 max-h-[300px] overflow-y-auto custom-scrollbar">
                {labels.map((lbl) => (
                  <button
                    key={lbl.id}
                    onClick={() => !isReadOnly && setSelectedLabelId(lbl.id)}
                    disabled={isReadOnly}
                    className={`flex items-center justify-between p-3 rounded-xl border transition-all ${
                      selectedLabelId === lbl.id
                        ? "bg-blue-600 border-blue-600 text-white shadow-md"
                        : "bg-gray-50 border-gray-100 text-gray-600 hover:border-blue-300"
                    } ${isReadOnly ? "cursor-default opacity-80" : ""}`}
                  >
                    <span className="font-bold text-sm">{lbl.name}</span>
                    <span className="text-[10px] opacity-70">ID: {lbl.yoloClassId}</span>
                  </button>
                ))}
                {labels.length === 0 && <p className="text-xs text-gray-400 italic">Đang tải danh sách nhãn...</p>}
              </div>
            </Card>

            {/* Guideline Summary */}
            <Card className="flex-1 p-4 overflow-hidden flex flex-col">
              <h3 className="font-bold text-sm text-gray-700 uppercase tracking-wider mb-3">Hướng dẫn</h3>
              <div className="flex-1 overflow-y-auto custom-scrollbar text-sm text-gray-500 italic leading-relaxed bg-blue-50/50 p-3 rounded-lg border border-blue-100">
                {guideline || "Không có hướng dẫn cụ thể cho bước này."}
              </div>
            </Card>

            {/* Stats */}
            <Card className="p-4 bg-gray-50 border-none">
              <div className="flex justify-between items-center text-xs font-bold text-gray-400 uppercase">
                <span>Tổng số nhãn</span>
                <span className="text-blue-600 text-lg">{boxes.length}</span>
              </div>
              {boxes.some(b => b.isAiSuggestion) && (
                <div className="mt-2 text-[10px] text-amber-600 flex items-center gap-1 font-medium">
                  <Bot size={12} /> Có {boxes.filter(b => b.isAiSuggestion).length} gợi ý AI cần xử lý
                </div>
              )}
            </Card>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}


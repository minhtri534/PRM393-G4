import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import DashboardLayout from "../../layouts/DashboardLayout";
import { reviewerService } from "../../services/reviewerService";
import type { 
  ReviewerLabeledDataResponse, 
  ReviewerAnnotationItemResponse,
  GuidelineComparisonResponse,
  LabelConsistencyValidationResponse
} from "../../services/reviewerService";
import { Button } from "../../components/ui/Button";
import { Card } from "../../components/ui/Card";
import { Textarea } from "../../components/ui/Textarea";
import { Check, X, Loader2, Info, AlertTriangle, CheckCircle2, ZoomIn, ZoomOut, RotateCcw } from "lucide-react";

const ReviewerTaskDetailPage: React.FC = () => {
  const { taskId } = useParams<{ taskId: string }>();
  const navigate = useNavigate();
  const [data, setData] = useState<ReviewerLabeledDataResponse | null>(null);
  const [guidelineResult, setGuidelineResult] = useState<GuidelineComparisonResponse | null>(null);
  const [consistencyResult, setConsistencyResult] = useState<LabelConsistencyValidationResponse | null>(null);
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [imageNaturalSize, setImageNaturalSize] = useState<{ width: number; height: number } | null>(null);
  const [zoom, setZoom] = useState(1);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [comment, setComment] = useState("");

  const CANVAS_BASE_WIDTH = 800;
  const scaleX = imageNaturalSize ? CANVAS_BASE_WIDTH / imageNaturalSize.width : 1;
  const scaleY = imageNaturalSize ? (CANVAS_BASE_WIDTH * imageNaturalSize.height) / imageNaturalSize.width / imageNaturalSize.height : 1;

  useEffect(() => {
    if (!taskId) return;
    setLoading(true);
    
    Promise.all([
      reviewerService.openLabeledData(taskId),
      reviewerService.getImageSecure(taskId),
      reviewerService.compareWithGuideline(taskId),
      reviewerService.validateConsistency(taskId)
    ]).then(([dataRes, imageBlob, guidelineRes, consistencyRes]) => {
      if (dataRes.isSuccess) {
        setData(dataRes.data || null);
      }
      if (imageBlob) {
        const url = URL.createObjectURL(imageBlob);
        setImageUrl(url);
      }
      if (guidelineRes.isSuccess) {
        setGuidelineResult(guidelineRes.data || null);
      }
      if (consistencyRes.isSuccess) {
        setConsistencyResult(consistencyRes.data || null);
      }
    }).finally(() => setLoading(false));

    return () => {
      if (imageUrl) URL.revokeObjectURL(imageUrl);
    };
  }, [taskId]);

  const parseGeometry = (geo: any) => {
    if (!geo) return null;
    let parsed = geo;
    try {
      if (typeof parsed === 'string') {
        parsed = JSON.parse(parsed);
        // Handle double-encoded string
        if (typeof parsed === 'string') {
          parsed = JSON.parse(parsed);
        }
      }
      return parsed;
    } catch (e) {
      console.error("Error parsing geometry:", e, geo);
      return null;
    }
  };

  const handleSubmit = async (isApproved: boolean) => {
    if (!taskId) return;
    setSubmitting(true);

    try {
      if (isApproved) {
        const res = await reviewerService.approveTask(taskId, {
          score: 100,
          comment: comment || "Approved"
        });
        if (res.isSuccess) {
          alert("Task approved successfully");
          navigate("/reviewer/tasks");
        } else {
          alert(res.message || "Failed to approve task");
        }
      } else {
        if (!comment.trim()) {
          alert("Please provide feedback for rejection");
          return;
        }
        const res = await reviewerService.returnTask(taskId, {
          feedback: comment,
          errorTypeIds: [] // Default empty for now
        });
        if (res.isSuccess) {
          alert("Task returned with feedback");
          navigate("/reviewer/tasks");
        } else {
          alert(res.message || "Failed to return task");
        }
      }
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center min-h-[400px]">
          <Loader2 className="animate-spin text-blue-600" size={32} />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="max-w-4xl mx-auto">
        <h1 className="text-2xl font-bold mb-4">Review Task #{taskId?.slice(-6)}</h1>
        
        {/* Labeled Data Card */}
        <Card className="p-6 mb-6">
          <div className="flex justify-between items-start mb-6">
            <h2 className="font-bold text-gray-900 text-xl">Labeled Data Review</h2>
            <div className="flex items-center gap-4">
              <div className="flex bg-gray-100 p-1 rounded-lg">
                <Button variant="ghost" size="sm" onClick={() => setZoom(z => Math.max(0.2, z - 0.2))} className="h-8 w-8 p-0">
                  <ZoomOut size={16} />
                </Button>
                <div className="flex items-center justify-center w-16 text-xs font-mono font-bold text-gray-600">
                  {Math.round(zoom * 100)}%
                </div>
                <Button variant="ghost" size="sm" onClick={() => setZoom(z => Math.min(5, z + 0.2))} className="h-8 w-8 p-0">
                  <ZoomIn size={16} />
                </Button>
                <div className="w-[1px] bg-gray-300 mx-1 h-6 self-center" />
                <Button variant="ghost" size="sm" onClick={() => setZoom(1)} title="Reset Zoom" className="h-8 w-8 p-0">
                  <RotateCcw size={16} />
                </Button>
              </div>

              <div className="flex gap-2">
                {guidelineResult && (
                  <div className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${
                    guidelineResult.isCompliant ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                  }`}>
                    {guidelineResult.isCompliant ? <CheckCircle2 size={14} /> : <AlertTriangle size={14} />}
                    Guideline: {guidelineResult.isCompliant ? 'Compliant' : 'Non-compliant'}
                  </div>
                )}
                {consistencyResult && (
                  <div className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${
                    consistencyResult.isValid ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                  }`}>
                    {consistencyResult.isValid ? <CheckCircle2 size={14} /> : <AlertTriangle size={14} />}
                    Labels: {consistencyResult.isValid ? 'Consistent' : 'Inconsistent'}
                  </div>
                )}
              </div>
            </div>
          </div>
          
          {/* Image Workspace - EXACT structure as Annotator */}
          <Card className="flex-1 bg-gray-900 relative overflow-auto custom-scrollbar flex items-center justify-center p-8 min-h-[600px] shadow-inner mb-6">
            {imageUrl ? (
              <div 
                className="relative shadow-2xl transition-transform duration-200"
                style={{
                  width: "fit-content",
                  height: "fit-content"
                }}
              >
                <img 
                  src={imageUrl} 
                  alt="Task item" 
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
                
                {/* Annotation Overlay - EXACT logic as Annotator page */}
                {data?.annotations.map(ann => {
                  const geo = parseGeometry(ann.geometryData);
                  if (!geo || geo.type !== 'bbox') return null;
                  
                  return (
                    <div 
                      key={ann.annotationId}
                      className="absolute border-2 border-emerald-400 bg-emerald-400/20 group cursor-default"
                      style={{
                        left: geo.x * scaleX * zoom,
                        top: geo.y * scaleY * zoom,
                        width: geo.width * scaleX * zoom,
                        height: geo.height * scaleY * zoom,
                      }}
                    >
                      <div className="absolute -top-6 left-0 bg-emerald-500 text-white text-[10px] px-1.5 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap font-bold">
                        {ann.labelName}
                      </div>
                    </div>
                  );
                })}
              </div>
            ) : (
              <div className="py-20 text-gray-400">Image not available</div>
            )}
          </Card>

          {/* Validation Insights */}
          {(guidelineResult?.mismatches?.length || 0) > 0 || (consistencyResult?.inconsistentLabels?.length || 0) > 0 ? (
            <div className="mb-6 space-y-3">
              <h3 className="text-sm font-bold text-gray-700 flex items-center gap-2">
                <Info size={16} className="text-blue-500" /> Automated Validation Insights
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {guidelineResult && guidelineResult.mismatches.length > 0 && (
                  <div className="p-3 bg-red-50 border border-red-100 rounded-lg">
                    <span className="text-xs font-bold text-red-600 uppercase">Guideline Mismatches</span>
                    <ul className="mt-2 space-y-1">
                      {guidelineResult.mismatches.map((m, i) => (
                        <li key={i} className="text-xs text-red-800 flex items-center gap-2">
                          <AlertTriangle size={12} /> {m}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
                {consistencyResult && consistencyResult.inconsistentLabels.length > 0 && (
                  <div className="p-3 bg-amber-50 border border-amber-100 rounded-lg">
                    <span className="text-xs font-bold text-amber-600 uppercase">Consistency Issues</span>
                    <ul className="mt-2 space-y-1">
                      {consistencyResult.inconsistentLabels.map((l, i) => (
                        <li key={i} className="text-xs text-amber-800 flex items-center gap-2">
                          <AlertTriangle size={12} /> Inconsistent label: {l}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            </div>
          ) : null}

          <div className="grid grid-cols-2 gap-4 mb-6 text-sm">
            <div className="p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-500 block">Storage Provider</span>
              <span className="font-medium">{data?.storageProvider}</span>
            </div>
            <div className="p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-500 block">Object Key</span>
              <span className="font-medium truncate block" title={data?.objectKey}>{data?.objectKey}</span>
            </div>
          </div>
          
          <h3 className="font-semibold mb-3 text-sm text-gray-700">Annotation Details ({data?.annotations.length || 0})</h3>
          <div className="space-y-2">
            {data?.annotations.map(ann => (
              <div key={ann.annotationId} className="p-3 border rounded-lg bg-gray-50 flex justify-between items-center text-sm">
                <div>
                  <span className="font-medium text-gray-900">{ann.labelName}</span>
                  <p className="text-xs text-gray-500 mt-1">ID: {ann.annotationId.slice(-8)} • Type: {ann.annotationType}</p>
                </div>
                <div className="text-xs font-mono bg-white px-2 py-1 rounded border shadow-sm max-w-[300px] truncate">
                  {ann.geometryData}
                </div>
              </div>
            ))}
            {(!data?.annotations || data.annotations.length === 0) && (
              <p className="text-gray-400 italic text-sm py-4 text-center">No annotations found for this task.</p>
            )}
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="font-bold mb-4 text-gray-900">Review Decision</h2>
          <Textarea 
            placeholder="Add a comment or feedback..."
            value={comment}
            onChange={e => setComment(e.target.value)}
            className="mb-6 min-h-[120px]"
          />
          <div className="flex gap-4">
            <Button 
              onClick={() => handleSubmit(true)} 
              disabled={submitting}
              className="bg-green-600 hover:bg-green-700 flex-1 h-11"
            >
              {submitting ? <Loader2 className="animate-spin mr-2" /> : <Check className="mr-2" />} 
              Approve
            </Button>
            <Button 
              onClick={() => handleSubmit(false)} 
              disabled={submitting}
              variant="danger" 
              className="flex-1 h-11"
            >
              {submitting ? <Loader2 className="animate-spin mr-2" /> : <X className="mr-2" />} 
              Return for Rework
            </Button>
          </div>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default ReviewerTaskDetailPage;

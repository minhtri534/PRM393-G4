import React, { useEffect, useMemo, useState } from "react";
import { useParams, Link } from "react-router-dom";
import { Card } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import DashboardLayout from "../../layouts/DashboardLayout";
import { ArrowLeft, PlayCircle, FileText, Clock, CheckCircle, Loader2, MessageSquareWarning } from "lucide-react";
import { annotatorService } from "../../services/annotatorService";
import type { AnnotatorTaskSummary, ReviewFeedback, ErrorCategory } from "../../types/annotator"; // Thêm ErrorCategory

const AnnotatorTaskDetailPage: React.FC = () => {
  const { taskId } = useParams<{ taskId: string }>();
  const [task, setTask] = useState<AnnotatorTaskSummary | null>(null);
  const [guideline, setGuideline] = useState<string>("Loading guideline...");
  
  // FIX TS2304: Khai báo state cho feedback
  const [feedback, setFeedback] = useState<ReviewFeedback[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      if (!taskId) {
        setLoading(false);
        return;
      }

      setLoading(true);
      try {
        // Fetch base task info first to determine if we need feedback
        const taskRes = await annotatorService.getMyTasks();
        let currentTask: AnnotatorTaskSummary | null = null;
        if (taskRes.isSuccess) {
          currentTask = (taskRes.data || []).find((t) => t.id === taskId) || null;
          setTask(currentTask);
        }

        // Only fetch feedback if the task status indicates it might have one
        const needsFeedback = currentTask && ["Returned", "Rejected", "Rework", "Completed"].includes(currentTask.status);
        const feedbackPromise = needsFeedback 
          ? annotatorService.getReviewFeedback(taskId).catch(() => ({ isSuccess: false, data: null }))
          : Promise.resolve({ isSuccess: false, data: null });

        const [guidelineRes, feedbackRes] = await Promise.all([
          annotatorService.getGuideline(taskId),
          feedbackPromise,
        ]);

        if (guidelineRes.isSuccess) {
          setGuideline(guidelineRes.data?.guideline || "No specific guideline for this project.");
        }

        if (feedbackRes.isSuccess && feedbackRes.data) {
          const data = Array.isArray(feedbackRes.data) ? feedbackRes.data : [feedbackRes.data];
          setFeedback(data);
        }
      } catch (err) {
        console.error("Error loading task details:", err);
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [taskId]);

  const statusLabel = useMemo(() => {
    if (!task) return "Unknown";
    if (task.status === "InProgress") return "In Progress";
    if (task.status === "Assigned") return "Assigned";
    if (task.status === "Submitted") return "Submitted";
    if (task.status === "Returned") return "Needs Revision";
    return task.status;
  }, [task]);

  if (loading) {
    return (
      <DashboardLayout>
        <div className="h-96 flex flex-col items-center justify-center gap-3 text-gray-600">
          <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
          <p>Loading task details...</p>
        </div>
      </DashboardLayout>
    );
  }

  if (!task) {
    return (
      <DashboardLayout>
        <div className="max-w-4xl mx-auto py-20">
          <Card className="p-12 text-center text-gray-500 border-dashed">
            Task not found or you do not have access.
          </Card>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="max-w-5xl mx-auto space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Link to="/annotator/tasks">
              <Button variant="ghost" size="icon" className="rounded-full hover:bg-gray-100">
                <ArrowLeft className="h-6 w-6" />
              </Button>
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Task Details #{task.id.slice(-6)}</h1>
              <p className="text-gray-500 mt-1">Task details and instructions.</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            {/* Show "View" button for Submitted/Completed, "Start/Revise" for others */}
            {["Submitted", "Completed"].includes(task.status) ? (
              <Link to={`/annotator/ai-label/${taskId}`}>
                <Button variant="outline" className="border-blue-600 text-blue-600 hover:bg-blue-50 px-6">
                  <FileText className="h-4 w-4 mr-2" />
                  Xem lại bài làm
                </Button>
              </Link>
            ) : (
              <Link to={`/annotator/ai-label/${taskId}`}>
                <Button variant="primary" className="bg-blue-600 hover:bg-blue-700 px-6">
                  <PlayCircle className="h-4 w-4 mr-2" />
                  {["Returned", "Rejected"].includes(task.status) ? "Sửa lại bài làm" : "Bắt đầu dán nhãn"}
                </Button>
              </Link>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <Card className="p-8 col-span-2 space-y-8 border-none shadow-sm">
            <div className="space-y-3">
              <h3 className="text-xl font-bold text-gray-800 flex items-center gap-2">
                <FileText className="text-blue-600 h-5 w-5" />
                Task Description
              </h3>
              <div className="p-4 bg-gray-50 rounded-xl text-gray-600 border border-gray-100">
                This task belongs to project <span className="font-semibold text-gray-900">{task.projectId}</span>.
                You need to label the data item <span className="font-semibold text-gray-900">{task.dataItemId}</span>
                according to the project guideline.
              </div>
            </div>

            <div className="space-y-3">
              <h3 className="text-xl font-bold text-gray-800">Guidelines</h3>
              <div className="bg-blue-50/50 p-6 rounded-xl border border-blue-100 text-blue-900 whitespace-pre-wrap italic">
                {guideline}
              </div>
            </div>

            {/* Only show progress for active tasks */}
            {!["Submitted", "Completed"].includes(task.status) && (
              <div className="pt-6 border-t border-gray-100">
                <h3 className="text-lg font-bold text-gray-800 mb-4 text-center">Current Progress</h3>
                <div className="max-w-md mx-auto">
                  <div className="w-full bg-gray-100 rounded-full h-3">
                    <div
                      className="bg-blue-600 h-3 rounded-full transition-all duration-500"
                      style={{ width: `${task.status === "InProgress" ? 50 : 10}%` }}
                    ></div>
                  </div>
                  <div className="flex justify-between items-center mt-3 text-sm">
                    <span className="text-gray-500">Status: <span className="font-bold text-blue-600 uppercase tracking-wide ml-1">{statusLabel}</span></span>
                    <span className="text-gray-400 font-medium">{task.status === "InProgress" ? "50%" : "0%"}</span>
                  </div>
                </div>
              </div>
            )}
          </Card>

          <div className="space-y-6">
            <Card className="p-6 space-y-6 h-fit border-none shadow-sm">
              <div>
                <h3 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">
                  Status
                </h3>
                <div className="flex items-center gap-2 text-green-600 font-bold text-lg">
                  <CheckCircle className="h-6 w-6" />
                  {statusLabel}
                </div>
              </div>
              
              <div className="pt-6 border-t border-gray-50">
                <h3 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">
                  Thời gian giao
                </h3>
                <div className="flex items-center gap-2 text-gray-700 font-medium">
                  <Clock className="h-5 w-5 text-gray-400" />
                  {task.assignedAt ? new Date(task.assignedAt).toLocaleString('en-US') : "-"}
                </div>
              </div>

              {/* Hiển thị feedback cho trạng thái Returned, Rework hoặc Completed */}
              {(task.status === "Returned" || task.status === "Rework" || task.status === "Completed") && feedback.length > 0 && (
                <div className="pt-6 border-t border-red-100">
                  <h3 className="text-xs font-bold text-red-500 uppercase tracking-widest mb-3 flex items-center gap-2">
                    <MessageSquareWarning className="h-4 w-4" />
                    Feedback from Reviewer
                  </h3>
                  {feedback.map((fb: ReviewFeedback) => ( 
                    <div key={fb.id || `feedback-${fb.createdAt}`} className={`p-4 rounded-lg text-sm mb-3 border ${
                      task.status === "Completed" ? "bg-green-50 text-green-800 border-green-100" : "bg-red-50 text-red-800 border-red-100"
                    }`}>
                      <p className="italic">“{fb.comment}”</p>
                      <div className="flex flex-wrap gap-2 mt-3">
                        {(fb.errorCategories || []).map((cat: ErrorCategory) => ( 
                          <span key={cat.errorTypeId || cat.errorName} className={`px-2 py-1 rounded-md text-xs font-semibold ${
                            task.status === "Completed" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"
                          }`}>
                            {cat.errorName}
                          </span>
                        ))}
                      </div>
                      <p className={`text-xs mt-2 text-right ${
                        task.status === "Completed" ? "text-green-400" : "text-red-400"
                      }`}>
                        {fb.createdAt ? new Date(fb.createdAt).toLocaleString() : ""}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </Card>

            <Card className="p-6 bg-gray-900 text-white border-none shadow-xl">
              <h3 className="font-bold mb-2">Need help?</h3>
              <p className="text-xs text-gray-400 leading-relaxed">
                If you encounter issues while labeling, contact the Project Manager or refer to the project Guideline.
              </p>
            </Card>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default AnnotatorTaskDetailPage;
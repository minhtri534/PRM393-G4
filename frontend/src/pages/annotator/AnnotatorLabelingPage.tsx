import { Navigate, useParams } from "react-router-dom";

export default function AnnotatorLabelingPage() {
  const { taskId } = useParams<{ taskId: string }>();

  if (!taskId) {
    return <Navigate to="/annotator/tasks" replace />;
  }

  return <Navigate to={`/annotator/ai-label/${taskId}`} replace />;
}

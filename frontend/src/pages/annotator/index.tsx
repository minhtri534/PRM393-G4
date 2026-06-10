import React from "react";
import { Route, Routes, Navigate } from "react-router-dom";
import AnnotatorTaskListPage from "./AnnotatorTaskListPage";
import AnnotatorTaskDetailPage from "./AnnotatorTaskDetailPage";
import AnnotatorAILabelPage from "./AnnotatorAILabelPage";
import AnnotatorLabelingPage from "./AnnotatorLabelingPage";

export default function AnnotatorRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="tasks" replace />} />
      <Route path="/tasks" element={<AnnotatorTaskListPage />} />
      <Route path="/task/:taskId" element={<AnnotatorTaskDetailPage />} />
      <Route path="/task/:taskId/label" element={<AnnotatorLabelingPage />} />
      <Route path="/ai-label" element={<AnnotatorAILabelPage />} />
      <Route path="/ai-label/:id" element={<AnnotatorAILabelPage />} />
      <Route path="/rework/:id" element={<AnnotatorAILabelPage />} />
    </Routes>
  );
}

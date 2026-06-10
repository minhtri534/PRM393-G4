import React from "react";
import { Route, Routes, Navigate } from "react-router-dom";
import ReviewerTaskListPage from "./ReviewerTaskListPage";
import ReviewerTaskDetailPage from "./ReviewerTaskDetailPage";

export default function ReviewerRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="tasks" replace />} />
      <Route path="/tasks" element={<ReviewerTaskListPage />} />
      <Route path="/task/:taskId" element={<ReviewerTaskDetailPage />} />
    </Routes>
  );
}

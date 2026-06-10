export type { ServiceResponse } from "../services/authService";

export interface AnnotatorTaskSummary {
  id: string;
  projectId: string;
  dataItemId: string;
  status: string;
  assignedAt?: string | null;
  completedAt?: string | null;
}

export interface AnnotatorTaskDetail extends AnnotatorTaskSummary {}

export interface TaskLabel {
  id: string;
  name: string;
  color: string;
}

export interface Annotation {
  id: string;
  labelId: string;
  geometryData: any; 
}

export interface AnnotatorAnnotation extends Annotation {
  taskId: string;
}

export interface AISuggestion {
  id: string;
  labelId: string;
  geometryData: any;
  confidence: number;
}

export interface AiAssistSuggestResponse {
  runId: string;
  objects: AISuggestion[];
}

export interface ErrorCategory {
  errorTypeId: string;
  errorName: string;
}

export interface ReviewFeedback {
  id: string;
  score: number;
  comment: string;
  errorCategories: ErrorCategory[]; 
  createdAt?: string;
  // Thêm alias categories để tương thích với code cũ dùng .categories
  categories: ErrorCategory[];
}

// FIX TS2305: Export alias để trang cũ không bị lỗi
export type AnnotatorReviewFeedbackResponse = ReviewFeedback;

export interface AnnotatorTaskItem {
  id: string;
  taskId: string;
  content: string;
  contentType: string;
}

export interface LabelResponse {
  id: string;
  name: string;
  color: string;
  projectId: string;
  yoloClassId: number; 
}

export interface ProjectGuideline {
  projectId: string;
  guideline: string;
}

// Sửa annotations -> objects
export interface UpsertTaskAnnotationsPayload {
  objects: Partial<Annotation>[];
  predictionId?: string;
}
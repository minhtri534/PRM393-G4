import api from "../lib/axios";
import type {
  AiAssistSuggestResponse,
  AnnotatorAnnotation,
  AnnotatorTaskItem,
  AnnotatorTaskSummary,
  LabelResponse,
  ProjectGuideline,
  ServiceResponse,
  UpsertTaskAnnotationsPayload,
  ReviewFeedback,
} from "../types/annotator";

export interface RejectTaskRequest {
  reason?: string;
}

export const annotatorService = {
  async getMyTasks() {
    const res = await api.get<ServiceResponse<AnnotatorTaskSummary[]>>("/annotator/tasks");
    return res.data;
  },

  async acceptTask(taskId: string) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/accept`);
    return res.data;
  },

  async rejectTask(taskId: string, data: RejectTaskRequest) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/reject`, data);
    return res.data;
  },

  async startTask(taskId: string) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/start`);
    return res.data;
  },

  async getTaskItems(taskId: string) {
    const res = await api.get<ServiceResponse<AnnotatorTaskItem[]>>(`/annotator/tasks/${taskId}/items`);
    return res.data;
  },

  async getLabels(taskId: string) {
    const res = await api.get<ServiceResponse<LabelResponse[]>>(`/annotator/tasks/${taskId}/labels`);
    return res.data;
  },

  async getGuideline(taskId: string) {
    const res = await api.get<ServiceResponse<ProjectGuideline>>(`/annotator/tasks/${taskId}/guideline`);
    return res.data;
  },

  async getAnnotations(taskId: string) {
    const res = await api.get<ServiceResponse<AnnotatorAnnotation[]>>(`/annotator/tasks/${taskId}/annotations`);
    return res.data;
  },

  async saveDraft(taskId: string, data: UpsertTaskAnnotationsPayload) {
    const res = await api.put<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/annotations/draft`, data);
    return res.data;
  },

  async submit(taskId: string, data: UpsertTaskAnnotationsPayload) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/annotations/submit`, data);
    return res.data;
  },

  async suggestAi(taskId: string, apply = false, labelId?: string) {
    const query = new URLSearchParams({ apply: String(apply) });
    if (labelId && labelId.trim().length > 0) {
      query.set("labelId", labelId.trim());
    }

    const res = await api.post<ServiceResponse<AiAssistSuggestResponse>>(
      `/annotator/tasks/${taskId}/ai-suggest?${query.toString()}`
    );
    return res.data;
  },

  async getImageSecure(taskId: string): Promise<Blob> {
    const res = await api.get(`/annotator/tasks/${taskId}/data-item/content`, { responseType: "blob" });
    return res.data as Blob;
  },

  async createTaskAnnotation(taskId: string, data: any) {
    const res = await api.post<ServiceResponse<any>>(`/annotator/tasks/${taskId}/annotations`, data);
    return res.data;
  },

  async updateTaskAnnotation(taskId: string, annotationId: string, data: any) {
    const res = await api.put<ServiceResponse<any>>(`/annotator/tasks/${taskId}/annotations/${annotationId}`, data);
    return res.data;
  },

  async deleteTaskAnnotation(taskId: string, annotationId: string) {
    const res = await api.delete<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/annotations/${annotationId}`);
    return res.data;
  },

  async getReviewFeedback(taskId: string) {
    const res = await api.get<ServiceResponse<ReviewFeedback[]>>(`/annotator/tasks/${taskId}/review-feedback`);
    return res.data;
  },

  async getReviewErrorCategories(reviewId: string) {
    const res = await api.get<ServiceResponse<any>>(`/annotator/reviews/${reviewId}/error-categories`);
    return res.data;
  },

  async addCommentToReviewer(reviewId: string, comment: string) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/reviews/${reviewId}/comment`, { comment });
    return res.data;
  },

  async acceptAiSuggestion(taskId: string, predictionId: string) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/ai-suggestions/${predictionId}/accept`);
    return res.data;
  },

  async rejectAiSuggestion(taskId: string, predictionId: string, reason: string) {
    const res = await api.post<ServiceResponse<boolean>>(`/annotator/tasks/${taskId}/ai-suggestions/${predictionId}/reject`, { reason });
    return res.data;
  },
};
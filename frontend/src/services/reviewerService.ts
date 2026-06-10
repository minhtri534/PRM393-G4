import api from '../lib/axios';
import type { ServiceResponse } from './authService';

export interface ReviewerSubmittedTaskResponse {
  id: string;
  projectId: string;
  projectName: string;
  annotatorId: string;
  annotatorName: string;
  annotationSetId: string;
  submittedAt: string;
  annotationCount: number;
  status: string;
}

export interface ReviewerAnnotationItemResponse {
  annotationId: string;
  labelId: string;
  labelName: string;
  annotationType: string;
  geometryData: string;
}

export interface ReviewerLabeledDataResponse {
  taskId: string;
  annotationSetId: string;
  guideline?: string;
  storageProvider: string;
  objectKey: string;
  annotations: ReviewerAnnotationItemResponse[];
}

export interface GuidelineComparisonResponse {
  isCompliant: boolean;
  mismatches: string[];
}

export interface LabelConsistencyValidationResponse {
  isValid: boolean;
  inconsistentLabels: string[];
}

export interface ApproveLabeledDataRequest {
  score: number;
  comment?: string;
}

export interface ReturnLabelWithFeedbackRequest {
  feedback: string;
  errorTypeIds: string[];
}

export interface ReviewerErrorTypeResponse {
  id: string;
  name: string;
  description?: string;
}

export const reviewerService = {
  async getSubmittedTasks(): Promise<ServiceResponse<ReviewerSubmittedTaskResponse[]>> {
    const response = await api.get<ServiceResponse<ReviewerSubmittedTaskResponse[]>>('/reviewer/tasks/submitted');
    return response.data;
  },

  async openLabeledData(taskId: string): Promise<ServiceResponse<ReviewerLabeledDataResponse>> {
    const response = await api.get<ServiceResponse<ReviewerLabeledDataResponse>>(`/reviewer/tasks/${taskId}/labeled-data`);
    return response.data;
  },

  async compareWithGuideline(taskId: string): Promise<ServiceResponse<GuidelineComparisonResponse>> {
    const response = await api.get<ServiceResponse<GuidelineComparisonResponse>>(`/reviewer/tasks/${taskId}/guideline-comparison`);
    return response.data;
  },

  async validateConsistency(taskId: string): Promise<ServiceResponse<LabelConsistencyValidationResponse>> {
    const response = await api.get<ServiceResponse<LabelConsistencyValidationResponse>>(`/reviewer/tasks/${taskId}/consistency-validation`);
    return response.data;
  },

  async approveTask(taskId: string, data: ApproveLabeledDataRequest): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>(`/reviewer/tasks/${taskId}/approve`, data);
    return response.data;
  },

  async returnTask(taskId: string, data: ReturnLabelWithFeedbackRequest): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>(`/reviewer/tasks/${taskId}/return`, data);
    return response.data;
  },

  async getErrorTypes(): Promise<ServiceResponse<ReviewerErrorTypeResponse[]>> {
    const response = await api.get<ServiceResponse<ReviewerErrorTypeResponse[]>>('/reviewer/error-types');
    return response.data;
  },

  async createErrorRecord(reviewId: string, data: any): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>(`/reviewer/reviews/${reviewId}/errors`, data);
    return response.data;
  },

  async updateErrorRecord(reviewId: string, data: any): Promise<ServiceResponse<boolean>> {
    const response = await api.put<ServiceResponse<boolean>>(`/reviewer/reviews/${reviewId}/errors`, data);
    return response.data;
  },

  async getErrorStatistics(projectId?: string): Promise<ServiceResponse<any>> {
    const params = { projectId };
    const response = await api.get<ServiceResponse<any>>('/reviewer/error-statistics', { params });
    return response.data;
  },

  async getImageSecure(taskId: string): Promise<Blob> {
    const response = await api.get(`/reviewer/tasks/${taskId}/content`, {
      responseType: 'blob'
    });
    return response.data;
  }
};

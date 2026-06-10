import api from '../lib/axios';

export interface Review {
  id: string;
  annotationSetId: string;
  reviewerId: string;
  result: string;
  score: number;
  comment?: string;
  reviewedAt: string;
}

export interface ReviewError {
  reviewId: string;
  errorTypeId: string;
}

export interface ErrorType {
  id: string;
  errorName: string;
  description?: string;
}

export interface UpdateErrorTypeRequest {
  errorName: string;
  description?: string;
}

export const reviewApiService = {
  // Reviews
  async getAllReviews(): Promise<Review[]> {
    const response = await api.get<Review[]>('/reviews');
    return response.data;
  },

  async getReviewById(id: string): Promise<Review> {
    const response = await api.get<Review>(`/reviews/${id}`);
    return response.data;
  },

  // Review Errors (Admin only)
  async getAllReviewErrors(): Promise<ReviewError[]> {
    const response = await api.get<ReviewError[]>('/review_errors');
    return response.data;
  },

  // Error Types
  async getAllErrorTypes(): Promise<ErrorType[]> {
    const response = await api.get<ErrorType[]>('/error_type');
    return response.data;
  },

  async getErrorTypeById(id: string): Promise<ErrorType> {
    const response = await api.get<ErrorType>(`/error_type/${id}`);
    return response.data;
  },

  async addErrorType(data: UpdateErrorTypeRequest): Promise<void> {
    await api.post('/error_type', data);
  },

  async updateErrorType(data: UpdateErrorTypeRequest): Promise<void> {
    await api.put('/error_type', data);
  },

  async deleteErrorType(id: string): Promise<void> {
    await api.delete('/error_type', { data: id });
  }
};

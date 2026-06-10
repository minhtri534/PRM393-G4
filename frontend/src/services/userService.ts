import api from '../lib/axios';
import type { ServiceResponse } from './authService';

export interface UserResponse {
  id: string;
  fullName: string;
  email: string;
  phoneNumber?: string;
  identifyNumber?: string;
  gender?: string;
  address?: string;
  dateOfBirth?: string;
  roleId: string;
  roleName?: string;
  status: number;
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserRequest {
  fullName: string;
  email: string;
  password: string;
  roleId: string;
  status: number;
  phoneNumber?: string;
  identifyNumber?: string;
  gender?: string;
  address?: string;
  dateOfBirth?: string;
}

export interface UpdateUserRequest {
  fullName: string;
  email: string;
  password?: string;
  roleId: string;
  status: number;
  phoneNumber?: string;
  identifyNumber?: string;
  gender?: string;
  address?: string;
  dateOfBirth?: string;
}

export const userService = {
  async getAll(): Promise<ServiceResponse<UserResponse[]>> {
    const response = await api.get<ServiceResponse<UserResponse[]>>('/users');
    return response.data;
  },

  async getById(userId: string): Promise<ServiceResponse<UserResponse>> {
    const response = await api.get<ServiceResponse<UserResponse>>(`/users/${userId}`);
    return response.data;
  },

  async create(data: CreateUserRequest): Promise<ServiceResponse<UserResponse>> {
    const response = await api.post<ServiceResponse<UserResponse>>('/users', data);
    return response.data;
  },

  async update(userId: string, data: UpdateUserRequest): Promise<ServiceResponse<UserResponse>> {
    const response = await api.put<ServiceResponse<UserResponse>>(`/users/${userId}`, data);
    return response.data;
  },

  async delete(userId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete<ServiceResponse<boolean>>(`/users/${userId}`);
    return response.data;
  },

  async search(query: string, role?: string): Promise<ServiceResponse<UserSummaryResponse[]>> {
    const response = await api.get<ServiceResponse<UserSummaryResponse[]>>('/users/search', {
      params: { q: query, role }
    });
    return response.data;
  }
};

export interface UserSummaryResponse {
  id: string;
  fullName: string;
  email: string;
  roleName: string;
}

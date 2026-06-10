import api from '../lib/axios';
import type { ServiceResponse } from './authService';

export interface RoleResponse {
  id: string;
  name: string;
}

export interface CreateRoleRequest {
  name: string;
}

export interface UpdateRoleRequest {
  name: string;
}

export const roleService = {
  async getAll(): Promise<ServiceResponse<RoleResponse[]>> {
    const response = await api.get<ServiceResponse<RoleResponse[]>>('/roles');
    return response.data;
  },

  async create(data: CreateRoleRequest): Promise<ServiceResponse<RoleResponse>> {
    const response = await api.post<ServiceResponse<RoleResponse>>('/roles', data);
    return response.data;
  },

  async update(roleId: string, data: UpdateRoleRequest): Promise<ServiceResponse<RoleResponse>> {
    const response = await api.put<ServiceResponse<RoleResponse>>(`/roles/${roleId}`, data);
    return response.data;
  },

  async delete(roleId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete<ServiceResponse<boolean>>(`/roles/${roleId}`);
    return response.data;
  }
};

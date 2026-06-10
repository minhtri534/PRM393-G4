import api from '../lib/axios';
import type { ServiceResponse } from './authService';

export interface ResetUserPasswordRequest {
  newPassword: string;
}

export interface AssignRolePermissionRequest {
  roleId: string;
}

export interface AdminSystemSettingsResponse {
  maintenanceMode: boolean;
  allowRegistration: boolean;
  defaultUserRoleId: string;
  maxUploadSizeMb: number;
}

export interface UpdateSystemSettingsRequest {
  maintenanceMode?: boolean;
  allowRegistration?: boolean;
  defaultUserRoleId?: string;
  maxUploadSizeMb?: number;
}

export interface AdminSystemHealthResponse {
  status: string;
  databaseConnected: boolean;
  storageAvailable: boolean;
  uptimeSeconds: number;
  memoryUsageMb: number;
}

export interface AdminActivityLogResponse {
  id: string;
  userId: string;
  userEmail: string;
  action: string;
  entityName: string;
  entityId: string;
  timestamp: string;
  ipAddress: string;
  details: string;
}

export const adminService = {
  async disableUser(userId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.patch<ServiceResponse<boolean>>(`/admin/users/${userId}/disable`);
    return response.data;
  },

  async resetUserPassword(userId: string, data: ResetUserPasswordRequest): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>(`/admin/users/${userId}/reset-password`, data);
    return response.data;
  },

  async assignRole(userId: string, data: AssignRolePermissionRequest): Promise<ServiceResponse<boolean>> {
    const response = await api.put<ServiceResponse<boolean>>(`/admin/users/${userId}/role`, data);
    return response.data;
  },

  async getSystemSettings(): Promise<ServiceResponse<AdminSystemSettingsResponse>> {
    const response = await api.get<ServiceResponse<AdminSystemSettingsResponse>>('/admin/settings');
    return response.data;
  },

  async updateSystemSettings(data: UpdateSystemSettingsRequest): Promise<ServiceResponse<AdminSystemSettingsResponse>> {
    const response = await api.put<ServiceResponse<AdminSystemSettingsResponse>>('/admin/settings', data);
    return response.data;
  },

  async getSystemHealth(): Promise<ServiceResponse<AdminSystemHealthResponse>> {
    const response = await api.get<ServiceResponse<AdminSystemHealthResponse>>('/admin/health');
    return response.data;
  },

  async getActivityLogs(page = 1, pageSize = 50, userId?: string, action?: string): Promise<ServiceResponse<AdminActivityLogResponse[]>> {
    const params = { page, pageSize, userId, action };
    const response = await api.get<ServiceResponse<AdminActivityLogResponse[]>>('/admin/activity-logs', { params });
    return response.data;
  },

  async exportActivityLogs(format = "csv", userId?: string, action?: string): Promise<Blob> {
    const params = { format, userId, action };
    const response = await api.get('/admin/activity-logs/export', { 
      params,
      responseType: 'blob'
    });
    return response.data;
  }
};

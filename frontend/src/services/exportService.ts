import api from '../lib/axios';
import type { ServiceResponse } from './authService';

export interface YoloExportResponse {
  taskId: string;
  dataItemPath: string;
  labelFilePath: string;
  content: string;
  fileName: string;
}

export const exportService = {
  async exportYoloForTask(taskId: string): Promise<ServiceResponse<YoloExportResponse>> {
    const response = await api.get<ServiceResponse<YoloExportResponse>>(`/exports/yolo/tasks/${taskId}`);
    return response.data;
  }
};

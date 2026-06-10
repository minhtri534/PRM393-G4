import api from '../lib/axios';
import type { ServiceResponse } from './authService';
import type { 
  ProjectResponse,
  CreateProjectRequest,
  UpdateProjectRequest,
  DatasetResponse,
  CreateDatasetRequest,
  UpdateDatasetRequest,
  DatasetVersionResponse, 
  CreateDatasetVersionRequest,
  LabelResponse,
  CreateLabelRequest,
  UpdateLabelRequest,
  LabelCategoryResponse,
  CreateLabelCategoryRequest,
  UpdateLabelCategoryRequest,
  AnnotationTypeResponse,
  CreateAnnotationTypeRequest,
  UpdateAnnotationTypeRequest,
  TaskResponse,
  CreateTaskRequest,
  AssignTaskRequest,
  BulkAssignTasksRequest,
  BulkCreateTasksByDatasetRequest,
  RequestRelabelingRequest,
  TaskProgressResponse,
  TaskHistoryResponse,
  LabelingProgressOverviewResponse,
  AnnotatorPerformanceResponse,
  ReviewStatisticsResponse,
  InconsistentLabelResponse,
  QualityReportResponse,
  ExportResponse,
  CreateExportRequest,
  ExportValidationResponse,
  UserProjectRoleResponse,
  AssignUserProjectRoleRequest,
  UpdateProjectGuidelineRequest,
  ActivityLogResponse
} from '../types/manager';

export const managerService = {

  // ================= PROJECTS =================

  async getProjects(): Promise<ServiceResponse<ProjectResponse[]>> {
    const response = await api.get('/manager/projects');
    return response.data;
  },

  async getProjectById(projectId: string): Promise<ServiceResponse<ProjectResponse>> {
    const response = await api.get(`/manager/projects/${projectId}`);
    return response.data;
  },

  async createProject(data: CreateProjectRequest): Promise<ServiceResponse<ProjectResponse>> {
    const response = await api.post('/manager/projects', data);
    return response.data;
  },

  async updateProject(projectId: string, data: UpdateProjectRequest): Promise<ServiceResponse<ProjectResponse>> {
    const response = await api.put(`/manager/projects/${projectId}`, data);
    return response.data;
  },

  async deleteProject(projectId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete(`/manager/projects/${projectId}`);
    return response.data;
  },

  async archiveProject(projectId: string): Promise<ServiceResponse<ProjectResponse>> {
    const response = await api.post(`/manager/projects/${projectId}/archive`);
    return response.data;
  },

  // ✅ MISSING FIX
  async changeProjectStatus(projectId: string, data: UpdateProjectRequest): Promise<ServiceResponse<ProjectResponse>> {
    const response = await api.patch(`/manager/projects/${projectId}/status`, data);
    return response.data;
  },

  // ================= PROJECT ROLES =================

  async getProjectRoles(projectId: string): Promise<ServiceResponse<UserProjectRoleResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/project-roles`);
    return response.data;
  },

  async assignProjectRole(data: AssignUserProjectRoleRequest): Promise<ServiceResponse<UserProjectRoleResponse>> {
    const response = await api.post('/manager/project-roles', data);
    return response.data;
  },

  // ================= DATASETS =================

  async getDatasets(projectId: string): Promise<ServiceResponse<DatasetResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/datasets`);
    return response.data;
  },

  async getDatasetById(datasetId: string): Promise<ServiceResponse<DatasetResponse>> {
    const response = await api.get(`/manager/datasets/${datasetId}`);
    return response.data;
  },

  async createDataset(data: CreateDatasetRequest): Promise<ServiceResponse<DatasetResponse>> {
    const response = await api.post('/manager/datasets', data);
    return response.data;
  },

  async updateDataset(datasetId: string, data: UpdateDatasetRequest): Promise<ServiceResponse<DatasetResponse>> {
    const response = await api.put(`/manager/datasets/${datasetId}`, data);
    return response.data;
  },

  async deleteDataset(datasetId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete(`/manager/datasets/${datasetId}`);
    return response.data;
  },

  // ✅ MISSING FIX
  async createDatasetVersion(data: CreateDatasetVersionRequest): Promise<ServiceResponse<DatasetVersionResponse>> {
    const response = await api.post('/manager/dataset-versions', data);
    return response.data;
  },

  async getDatasetVersions(datasetId: string): Promise<ServiceResponse<DatasetVersionResponse[]>> {
    const response = await api.get(`/manager/datasets/${datasetId}/versions`);
    return response.data;
  },

  async restoreDatasetVersion(versionId: string): Promise<ServiceResponse<DatasetVersionResponse>> {
    const response = await api.post(`/manager/dataset-versions/${versionId}/restore`);
    return response.data;
  },

  async uploadDatasetFiles(datasetId: string, files: File[]): Promise<ServiceResponse<any>> {
    const formData = new FormData();
    formData.append('datasetId', datasetId);
    files.forEach(file => formData.append('files', file));

    const response = await api.post('/manager/datasets/upload-files', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    return response.data;
  },

  async uploadDatasetItems(data: any): Promise<ServiceResponse<any>> {
    const response = await api.post('/manager/datasets/upload', data);
    return response.data;
  },

  async importDatasetExternal(data: any): Promise<ServiceResponse<any>> {
    const response = await api.post('/manager/datasets/import-external', data);
    return response.data;
  },

  // ================= LABELS =================

  async getLabels(projectId: string): Promise<ServiceResponse<LabelResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/labels`);
    return response.data;
  },

  async createLabel(data: CreateLabelRequest): Promise<ServiceResponse<LabelResponse>> {
    const response = await api.post('/manager/labels', data);
    return response.data;
  },

  async updateLabel(labelId: string, data: UpdateLabelRequest): Promise<ServiceResponse<LabelResponse>> {
    const response = await api.put(`/manager/labels/${labelId}`, data);
    return response.data;
  },

  async deleteLabel(labelId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete(`/manager/labels/${labelId}`);
    return response.data;
  },

  // ================= LABEL CATEGORY =================

  async createLabelCategory(data: CreateLabelCategoryRequest): Promise<ServiceResponse<LabelCategoryResponse>> {
    const response = await api.post('/manager/label-categories', data);
    return response.data;
  },

  async getLabelCategories(projectId: string): Promise<ServiceResponse<LabelCategoryResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/label-categories`);
    return response.data;
  },

  async updateLabelCategory(categoryId: string, data: UpdateLabelCategoryRequest): Promise<ServiceResponse<LabelCategoryResponse>> {
    const response = await api.put(`/manager/label-categories/${categoryId}`, data);
    return response.data;
  },

  async deleteLabelCategory(categoryId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete(`/manager/label-categories/${categoryId}`);
    return response.data;
  },

  // ================= ANNOTATION TYPE =================

  async createAnnotationType(data: CreateAnnotationTypeRequest): Promise<ServiceResponse<AnnotationTypeResponse>> {
    const response = await api.post('/manager/annotation-types', data);
    return response.data;
  },

  async getAnnotationTypes(projectId: string): Promise<ServiceResponse<AnnotationTypeResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/annotation-types`);
    return response.data;
  },

  async updateAnnotationType(annotationTypeId: string, data: UpdateAnnotationTypeRequest): Promise<ServiceResponse<AnnotationTypeResponse>> {
    const response = await api.put(`/manager/annotation-types/${annotationTypeId}`, data);
    return response.data;
  },

  async deleteAnnotationType(annotationTypeId: string): Promise<ServiceResponse<boolean>> {
    const response = await api.delete(`/manager/annotation-types/${annotationTypeId}`);
    return response.data;
  },

  // ================= GUIDELINE =================

  async updateGuideline(projectId: string, guideline: string): Promise<ServiceResponse<ProjectResponse>> {
    const response = await api.patch(`/manager/projects/${projectId}/guideline`, { guideline });
    return response.data;
  },

  // ================= TASK =================

  async createTask(data: CreateTaskRequest): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post('/manager/tasks', data);
    return response.data;
  },

  async bulkCreateTasksByDataset(data: BulkCreateTasksByDatasetRequest): Promise<ServiceResponse<number>> {
    const response = await api.post('/manager/tasks/bulk-create-by-dataset', data);
    return response.data;
  },

  async assignTask(taskId: string, data: AssignTaskRequest): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post(`/manager/tasks/${taskId}/assign`, data);
    return response.data;
  },

  async bulkAssignTasks(data: BulkAssignTasksRequest): Promise<ServiceResponse<number>> {
    const response = await api.post('/manager/tasks/bulk-assign', data);
    return response.data;
  },

  async reassignTask(taskId: string, data: AssignTaskRequest): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post(`/manager/tasks/${taskId}/reassign`, data);
    return response.data;
  },

  async pauseTask(taskId: string): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post(`/manager/tasks/${taskId}/pause`);
    return response.data;
  },

  async resumeTask(taskId: string): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post(`/manager/tasks/${taskId}/resume`);
    return response.data;
  },

  async cancelTask(taskId: string): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post(`/manager/tasks/${taskId}/cancel`);
    return response.data;
  },

  async requestRelabeling(taskId: string, data: RequestRelabelingRequest): Promise<ServiceResponse<TaskResponse>> {
    const response = await api.post(`/manager/tasks/${taskId}/relabel`, data);
    return response.data;
  },

  async getTaskProgress(projectId: string): Promise<ServiceResponse<TaskProgressResponse>> {
    const response = await api.get(`/manager/projects/${projectId}/tasks/progress`);
    return response.data;
  },

  async getProjectTasks(projectId: string): Promise<ServiceResponse<TaskResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/tasks`);
    return response.data;
  },

  async getTaskHistory(taskId: string): Promise<ServiceResponse<TaskHistoryResponse[]>> {
    const response = await api.get(`/manager/tasks/${taskId}/history`);
    return response.data;
  },

  // ================= MONITORING =================

  async getLabelingOverview(projectId: string): Promise<ServiceResponse<LabelingProgressOverviewResponse>> {
    const response = await api.get(`/manager/projects/${projectId}/monitoring/overview`);
    return response.data;
  },

  async getAnnotatorPerformance(projectId: string): Promise<ServiceResponse<AnnotatorPerformanceResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/monitoring/annotator-performance`);
    return response.data;
  },

  async getReviewStats(projectId: string): Promise<ServiceResponse<ReviewStatisticsResponse>> {
    const response = await api.get(`/manager/projects/${projectId}/monitoring/review-stats`);
    return response.data;
  },

  async getInconsistentLabels(projectId: string): Promise<ServiceResponse<InconsistentLabelResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/monitoring/inconsistent-labels`);
    return response.data;
  },

  async getQualityReport(projectId: string): Promise<ServiceResponse<QualityReportResponse>> {
    const response = await api.get(`/manager/projects/${projectId}/monitoring/quality-report`);
    return response.data;
  },

  // ================= EXPORT =================

  async createExport(data: CreateExportRequest): Promise<ServiceResponse<ExportResponse>> {
    const response = await api.post('/manager/exports', data);
    return response.data;
  },

  async getProjectExports(projectId: string): Promise<ServiceResponse<ExportResponse[]>> {
    const response = await api.get(`/manager/projects/${projectId}/exports`);
    return response.data;
  },

  async validateApprovedData(projectId: string): Promise<ServiceResponse<ExportValidationResponse>> {
    const response = await api.get(`/manager/projects/${projectId}/exports/validate`);
    return response.data;
  },

  async downloadExport(exportId: string): Promise<void> {
    const response = await api.get(`/manager/exports/${exportId}/download`, { responseType: 'blob' });
    
    // response.data is already a Blob when using responseType: 'blob'
    const blob = response.data;
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    
    // Try to get filename from Content-Disposition header
    const contentDisposition = response.headers['content-disposition'];
    let fileName = `export-${exportId}`;
    
    if (contentDisposition) {
      // Handle various Content-Disposition formats
      const filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
      const matches = filenameRegex.exec(contentDisposition);
      if (matches != null && matches[1]) { 
        fileName = matches[1].replace(/['"]/g, '');
      }
    } else {
      // Fallback based on MIME type
      const extension = blob.type === 'application/zip' || blob.type === 'application/x-zip-compressed' ? '.zip' : '.json';
      if (!fileName.endsWith(extension)) {
        fileName += extension;
      }
    }
    
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
  },

  // ================= ACTIVITY LOG =================

  async getActivityLogs(projectId?: string, userId?: string, page = 1, pageSize = 50): Promise<ServiceResponse<ActivityLogResponse[]>> {
    const params = { projectId, userId, page, pageSize };
    const response = await api.get('/manager/activity-logs', { params });
    return response.data;
  }
};
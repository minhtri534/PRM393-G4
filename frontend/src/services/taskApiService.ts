import api from '../lib/axios';

export interface LabelingTask {
  id: string;
  projectId: string;
  dataItemId: string;
  annotatorId: string;
  assignedByUserId?: string;
  status: string;
  assignedAt?: string;
  completedAt?: string;
}

export const taskApiService = {
  async getAll(): Promise<LabelingTask[]> {
    const response = await api.get<LabelingTask[]>('/tasks');
    return response.data;
  },

  async getById(id: string): Promise<LabelingTask> {
    const response = await api.get<LabelingTask>(`/tasks/${id}`);
    return response.data;
  },

  async getSubmittedTasks(): Promise<LabelingTask[]> {
    const response = await api.get<LabelingTask[]>('/tasks/submitted');
    return response.data;
  },

  async create(task: LabelingTask): Promise<void> {
    await api.post('/tasks', task);
  },

  async update(task: LabelingTask): Promise<void> {
    await api.put('/tasks', task);
  },

  async delete(id: string): Promise<void> {
    await api.delete('/tasks', { data: id });
  }
};

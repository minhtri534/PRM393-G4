using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Services.LabelingTasks;

public interface ILabelingTasksService
{
    Task<List<LabelingTask>> GetAll();
    Task<LabelingTask?> GetLabelingTaskById(string id);
    Task<List<LabelingTask>> GetSubmittedLabelingTask();
    Task DeleteLabelingTask(string id);
    Task AddLabelingTask(LabelingTask task);
    Task UpdateLabelingTask(LabelingTask task);
}

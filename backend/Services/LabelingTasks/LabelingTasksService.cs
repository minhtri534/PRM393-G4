using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Repository;

namespace DataLabellingSupportSystem.Api.Services.LabelingTasks;

public class LabelingTasksService(LabelingTasksRepository repo) : ILabelingTasksService
{
    private readonly LabelingTasksRepository _repo = repo;

    public async Task AddLabelingTask(LabelingTask task)
    {
        await _repo.Add(task);
    }

    public async Task<List<LabelingTask>> GetAll()
    {
        return await _repo.GetAll();
    }

    public async Task UpdateLabelingTask(LabelingTask task)
    {
        await _repo.Update(task);
    }

    public async Task<LabelingTask?> GetLabelingTaskById(string id)
    {
        return await _repo.GetById(id);
    }

    public async Task DeleteLabelingTask(string id)
    {
        await _repo.Delete(id);
    }

    public async Task<List<LabelingTask>> GetSubmittedLabelingTask()
    {
        var results = await _repo.GetAll();
        return results.Where(a => a.Status == "Submitted").ToList();
    }
}

using Microsoft.EntityFrameworkCore;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Repository;

public class LabelingTasksRepository(AppDbContext dbContext)
{
    private readonly AppDbContext _dbContext = dbContext;

    public async Task<List<LabelingTask>> GetAll()
    {
        return await _dbContext.LabelingTasks.ToListAsync();
    }

    public async Task<LabelingTask?> GetById(string id)
    {
        return await _dbContext.LabelingTasks.FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task Add(LabelingTask t)
    {
        await _dbContext.LabelingTasks.AddAsync(t);
        await _dbContext.SaveChangesAsync();
    }

    public async Task Update(LabelingTask t)
    {
        var result = await _dbContext.LabelingTasks.FirstOrDefaultAsync(a => a.Id == t.Id);
        if (result != null)
        {
            result.AnnotatorId = t.AnnotatorId;
            result.AssignedAt = t.AssignedAt;
            result.AssignedByUserId = t.AssignedByUserId;
            result.CompletedAt = t.CompletedAt;
            result.DataItemId = t.DataItemId;
            result.ProjectId = t.ProjectId;
            result.Status = t.Status;
        }
        else
        {
            throw new Exception("Record not found");
        }
        await _dbContext.SaveChangesAsync();
    }

    public async Task Delete(string id)
    {
        var r = await _dbContext.LabelingTasks.FirstOrDefaultAsync(a => a.Id == id);
        if (r == null)
        {
            throw new Exception("Record not found");
        }
        _dbContext.LabelingTasks.Remove(r);
        await _dbContext.SaveChangesAsync();
    }
}
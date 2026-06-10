using Microsoft.EntityFrameworkCore;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;

namespace DataLabellingSupportSystem.Api.Repository;

public class ErrorTypesRepository(AppDbContext dbContext)
{
    private readonly AppDbContext _dbContext = dbContext;

    public async Task<List<ErrorType>> GetAll()
    {
        return await _dbContext.ErrorTypes.ToListAsync();
    }

    public async Task<ErrorType?> GetById(string id)
    {
        return await _dbContext.ErrorTypes.FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task Add(ErrorType r)
    {
        await _dbContext.ErrorTypes.AddAsync(r);
        await _dbContext.SaveChangesAsync();
    }

    public async Task Update(ErrorType r)
    {
        var result = await _dbContext.ErrorTypes.FirstOrDefaultAsync(a => a.Id == r.Id);
        if (result == null && !string.IsNullOrWhiteSpace(r.ErrorName))
        {
            result = await _dbContext.ErrorTypes.FirstOrDefaultAsync(a => a.ErrorName == r.ErrorName);
        }

        if (result != null)
        {
            result.Description = r.Description;
            result.ErrorName = r.ErrorName;
        }
        else
        {
            await _dbContext.ErrorTypes.AddAsync(new ErrorType
            {
                Id = ObjectId.NewObjectId(),
                ErrorName = r.ErrorName,
                Description = r.Description
            });
        }
        await _dbContext.SaveChangesAsync();
    }

    public async Task Delete(string id)
    {
        var r = await _dbContext.ErrorTypes.FirstOrDefaultAsync(a => a.Id == id);
        if (r == null)
        {
            throw new Exception("Record not found");
        }
        _dbContext.ErrorTypes.Remove(r);
        await _dbContext.SaveChangesAsync();
    }
}
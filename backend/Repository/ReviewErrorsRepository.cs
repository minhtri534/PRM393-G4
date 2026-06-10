using Microsoft.EntityFrameworkCore;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Repository;

public class ReviewErrorsRepository(AppDbContext dbContext)
{
    private readonly AppDbContext _dbContext = dbContext;

    public async Task<List<ReviewError>> GetAll()
    {
        return await _dbContext.ReviewErrors.ToListAsync();
    }
}
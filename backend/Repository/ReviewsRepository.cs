using Microsoft.EntityFrameworkCore;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Repository;

public class ReviewsRepository(AppDbContext dbContext)
{
    private readonly AppDbContext _dbContext = dbContext;

    public async Task<List<Review>> GetAll()
    {
        return await _dbContext.Reviews.ToListAsync();
    }

    public async Task<Review?> GetById(string id)
    {
        return await _dbContext.Reviews.FirstOrDefaultAsync(a => a.Id == id);
    }
}
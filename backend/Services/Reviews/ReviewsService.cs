using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Repository;

namespace DataLabellingSupportSystem.Api.Services.Reviews;

public class ReviewsService(ReviewsRepository repo) : IReviewsService
{
    private readonly ReviewsRepository _repo = repo;

    public async Task<List<Review>> GetAll()
    {
        return await _repo.GetAll();
    }

    public async Task<Review?> GetReviewById(string id)
    {
        return await _repo.GetById(id);
    }
}

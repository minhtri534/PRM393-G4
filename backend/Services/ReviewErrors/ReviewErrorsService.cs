using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Repository;

namespace DataLabellingSupportSystem.Api.Services.ReviewErrors;

public class ReviewErrorsService(ReviewErrorsRepository repo) : IReviewErrorsService
{
    private readonly ReviewErrorsRepository _repo = repo;

    public Task<List<ReviewError>> GetAll()
    {
        return _repo.GetAll();
    }
}

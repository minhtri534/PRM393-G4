using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Services.Reviews;

public interface IReviewsService
{
    Task<List<Review>> GetAll();
    Task<Review?> GetReviewById(string id);
}

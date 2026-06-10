using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Services.ReviewErrors;

public interface IReviewErrorsService
{
    Task<List<ReviewError>> GetAll();
}

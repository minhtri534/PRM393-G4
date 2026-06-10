using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Services.ErrorTypes;

public interface IErrorTypesService
{
    Task<List<ErrorType>> GetAll();
    Task<ErrorType?> GetErrorTypeById(string id);
    Task DeleteErrorType(string id);
    Task AddErrorType(ErrorType errorType);
    Task UpdateErrorType(ErrorType errorType);
}

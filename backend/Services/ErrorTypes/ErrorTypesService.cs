using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Repository;

namespace DataLabellingSupportSystem.Api.Services.ErrorTypes;

public class ErrorTypesService(ErrorTypesRepository repo) : IErrorTypesService
{
    private readonly ErrorTypesRepository _repo = repo;

    public async Task AddErrorType(ErrorType errorType)
    {
        await _repo.Add(errorType);
    }

    public async Task<List<ErrorType>> GetAll()
    {
        return await _repo.GetAll();
    }

    public async Task UpdateErrorType(ErrorType errorType)
    {
        await _repo.Update(errorType);
    }

    public async Task<ErrorType?> GetErrorTypeById(string id)
    {
        return await _repo.GetById(id);
    }

    public async Task DeleteErrorType(string id)
    {
        await _repo.Delete(id);
    }
}

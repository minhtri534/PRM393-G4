using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using DataLabellingSupportSystem.Api.DTOs.Responses.Users;

namespace DataLabellingSupportSystem.Api.Services.Users;

public interface IUsersService
{
    Task<ServiceResponse<List<UserResponse>>> GetAllAsync(string actorUserId);

    Task<ServiceResponse<UserResponse>> GetByIdAsync(string actorUserId, string userId);

    Task<ServiceResponse<UserResponse>> CreateAsync(string actorUserId, CreateUserRequest request);

    Task<ServiceResponse<UserResponse>> UpdateAsync(string actorUserId, string userId, UpdateUserRequest request);

    Task<ServiceResponse<bool>> DeleteAsync(string actorUserId, string userId);

    Task<ServiceResponse<List<UserSummaryResponse>>> SearchAsync(string actorUserId, string query, string? roleName = null);
}

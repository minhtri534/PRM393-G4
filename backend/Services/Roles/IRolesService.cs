using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Roles;
using DataLabellingSupportSystem.Api.DTOs.Responses.Roles;

namespace DataLabellingSupportSystem.Api.Services.Roles;

public interface IRolesService
{
    Task<ServiceResponse<List<RoleResponse>>> GetAllAsync();

    Task<ServiceResponse<RoleResponse>> CreateAsync(CreateRoleRequest request);

    Task<ServiceResponse<RoleResponse>> UpdateAsync(string roleId, UpdateRoleRequest request);

    Task<ServiceResponse<bool>> DeleteAsync(string roleId);
}

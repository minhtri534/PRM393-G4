using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Roles;
using DataLabellingSupportSystem.Api.DTOs.Responses.Roles;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Roles;

public sealed class RolesService(AppDbContext dbContext) : IRolesService
{
    public async Task<ServiceResponse<List<RoleResponse>>> GetAllAsync()
    {
        var roles = await dbContext.Roles
            .AsNoTracking()
            .OrderBy(x => x.Name)
            .Select(x => new RoleResponse(x.Id, x.Name))
            .ToListAsync();

        return ServiceResponse<List<RoleResponse>>.Success(roles, "OK");
    }

    public async Task<ServiceResponse<RoleResponse>> CreateAsync(CreateRoleRequest request)
    {
        var name = (request.Name ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            return ServiceResponse<RoleResponse>.Failure("Invalid role", ["Role name is required"]);
        }

        var exists = await dbContext.Roles.AsNoTracking().AnyAsync(x => x.Name == name);
        if (exists)
        {
            return ServiceResponse<RoleResponse>.Failure("Role already exists", ["Role name already exists"]);
        }

        var role = new Role
        {
            Id = ObjectId.NewObjectId(),
            Name = name
        };

        dbContext.Roles.Add(role);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<RoleResponse>.Success(new RoleResponse(role.Id, role.Name), "Created");
    }

    public async Task<ServiceResponse<RoleResponse>> UpdateAsync(string roleId, UpdateRoleRequest request)
    {
        var id = (roleId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<RoleResponse>.Failure("Invalid role", ["Role id is required"]);
        }

        var role = await dbContext.Roles.FirstOrDefaultAsync(x => x.Id == id);
        if (role is null)
        {
            return ServiceResponse<RoleResponse>.Failure(ErrorMessages.NotFound, ["Role not found"]);
        }

        var name = (request.Name ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            return ServiceResponse<RoleResponse>.Failure("Invalid role", ["Role name is required"]);
        }

        if (!string.Equals(role.Name, name, StringComparison.Ordinal))
        {
            var nameExists = await dbContext.Roles.AsNoTracking().AnyAsync(x => x.Name == name && x.Id != role.Id);
            if (nameExists)
            {
                return ServiceResponse<RoleResponse>.Failure("Role already exists", ["Role name already exists"]);
            }

            role.Name = name;
        }

        await dbContext.SaveChangesAsync();

        return ServiceResponse<RoleResponse>.Success(new RoleResponse(role.Id, role.Name), "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteAsync(string roleId)
    {
        var id = (roleId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid role", ["Role id is required"]);
        }

        var role = await dbContext.Roles.FirstOrDefaultAsync(x => x.Id == id);
        if (role is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Role not found"]);
        }

        var inUse = await dbContext.Users.AsNoTracking().AnyAsync(x => x.RoleId == id);
        if (inUse)
        {
            return ServiceResponse<bool>.Failure("Role is in use", ["Cannot delete role that is assigned to users"]);
        }

        dbContext.Roles.Remove(role);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Deleted");
    }
}

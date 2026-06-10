using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using DataLabellingSupportSystem.Api.DTOs.Responses.Users;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.Auth;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Users;

public sealed class UsersService(AppDbContext dbContext, IPasswordHasher passwordHasher) : IUsersService
{
    public async Task<ServiceResponse<List<UserResponse>>> GetAllAsync()
    {
        var users = await dbContext.Users
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new UserResponse(
                x.Id,
                x.FullName,
                x.Email,
                x.PhoneNumber,
                x.IdentifyNumber,
                x.Gender,
                x.Address,
                x.DateOfBirth,
                x.RoleId,
                x.Role != null ? x.Role.Name : null,
                x.Status,
                x.CreatedAt,
                x.UpdatedAt))
            .ToListAsync();

        return ServiceResponse<List<UserResponse>>.Success(users, "OK");
    }

    public async Task<ServiceResponse<UserResponse>> GetByIdAsync(string userId)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<UserResponse>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new UserResponse(
                x.Id,
                x.FullName,
                x.Email,
                x.PhoneNumber,
                x.IdentifyNumber,
                x.Gender,
                x.Address,
                x.DateOfBirth,
                x.RoleId,
                x.Role != null ? x.Role.Name : null,
                x.Status,
                x.CreatedAt,
                x.UpdatedAt))
            .FirstOrDefaultAsync();

        if (user is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        return ServiceResponse<UserResponse>.Success(user, "OK");
    }

    public async Task<ServiceResponse<UserResponse>> CreateAsync(CreateUserRequest request)
    {
        var normalizedEmail = NormalizeEmail(request.Email);

        var emailExists = await dbContext.Users.AsNoTracking().AnyAsync(x => x.Email == normalizedEmail);
        if (emailExists)
        {
            return ServiceResponse<UserResponse>.Failure("Email already exists", ["Email is already registered"]);
        }

        var role = await dbContext.Roles.AsNoTracking().FirstOrDefaultAsync(x => x.Id == request.RoleId);
        if (role is null)
        {
            return ServiceResponse<UserResponse>.Failure("Invalid role", ["Role not found"]);
        }

        var user = new User
        {
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            PhoneNumber = request.PhoneNumber,
            IdentifyNumber = request.IdentifyNumber,
            Gender = request.Gender,
            Address = request.Address,
            DateOfBirth = request.DateOfBirth,
            PasswordHash = passwordHasher.Hash(request.Password),
            RoleId = request.RoleId,
            Status = request.Status
        };

        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<UserResponse>.Success(
            new UserResponse(
                user.Id,
                user.FullName,
                user.Email,
                user.PhoneNumber,
                user.IdentifyNumber,
                user.Gender,
                user.Address,
                user.DateOfBirth,
                user.RoleId,
                role.Name,
                user.Status,
                user.CreatedAt,
                user.UpdatedAt),
            "Created");
    }

    public async Task<ServiceResponse<UserResponse>> UpdateAsync(string userId, UpdateUserRequest request)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<UserResponse>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var normalizedEmail = NormalizeEmail(request.Email);
        if (!string.Equals(user.Email, normalizedEmail, StringComparison.Ordinal))
        {
            var emailExists = await dbContext.Users.AsNoTracking().AnyAsync(x => x.Email == normalizedEmail && x.Id != user.Id);
            if (emailExists)
            {
                return ServiceResponse<UserResponse>.Failure("Email already exists", ["Email is already registered"]);
            }

            user.Email = normalizedEmail;
        }

        var role = await dbContext.Roles.AsNoTracking().FirstOrDefaultAsync(x => x.Id == request.RoleId);
        if (role is null)
        {
            return ServiceResponse<UserResponse>.Failure("Invalid role", ["Role not found"]);
        }

        user.FullName = request.FullName.Trim();
        user.PhoneNumber = request.PhoneNumber;
        user.IdentifyNumber = request.IdentifyNumber;
        user.Gender = request.Gender;
        user.Address = request.Address;
        user.DateOfBirth = request.DateOfBirth;
        user.RoleId = request.RoleId;
        user.Status = request.Status;

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            user.PasswordHash = passwordHasher.Hash(request.Password);
        }

        await dbContext.SaveChangesAsync();

        return ServiceResponse<UserResponse>.Success(
            new UserResponse(
                user.Id,
                user.FullName,
                user.Email,
                user.PhoneNumber,
                user.IdentifyNumber,
                user.Gender,
                user.Address,
                user.DateOfBirth,
                user.RoleId,
                role.Name,
                user.Status,
                user.CreatedAt,
                user.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteAsync(string userId)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        dbContext.Users.Remove(user);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Deleted");
    }

    public async Task<ServiceResponse<List<UserSummaryResponse>>> SearchAsync(string actorUserId, string query, string? roleName = null)
    {
        var actor = await dbContext.Users.AsNoTracking().Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == actorUserId);
        if (actor is null)
        {
            return ServiceResponse<List<UserSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var isActorAdmin = string.Equals(actor.Role?.Name, "Admin", StringComparison.OrdinalIgnoreCase);

        var normalizedQuery = (query ?? string.Empty).Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(normalizedQuery))
        {
            return ServiceResponse<List<UserSummaryResponse>>.Success([], "OK");
        }

        var usersQuery = dbContext.Users
            .AsNoTracking()
            .Include(u => u.Role)
            .Where(u => u.Email.ToLower().Contains(normalizedQuery) || u.FullName.ToLower().Contains(normalizedQuery));

        // Security filter: If not Admin, exclude other Admin/Manager roles
        if (!isActorAdmin)
        {
            usersQuery = usersQuery.Where(u => u.Role != null && 
                u.Role.Name != "Admin" && u.Role.Name != "Manager");
        }

        if (!string.IsNullOrWhiteSpace(roleName))
        {
            usersQuery = usersQuery.Where(u => u.Role != null && u.Role.Name == roleName);
        }

        var users = await usersQuery
            .OrderBy(u => u.FullName)
            .Take(20)
            .Select(u => new UserSummaryResponse(
                u.Id,
                u.FullName,
                u.Email,
                u.Role != null ? u.Role.Name : null))
            .ToListAsync();

        return ServiceResponse<List<UserSummaryResponse>>.Success(users, "OK");
    }

    private static string NormalizeEmail(string email) => (email ?? string.Empty).Trim().ToLowerInvariant();
}

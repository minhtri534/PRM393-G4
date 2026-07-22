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
    public async Task<ServiceResponse<List<UserResponse>>> GetAllAsync(string actorUserId)
    {
        var actor = await GetActorAsync(actorUserId);
        if (actor is null)
        {
            return ServiceResponse<List<UserResponse>>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var usersQuery = dbContext.Users.AsNoTracking().Include(x => x.Role).AsQueryable();
        if (!actor.IsAdmin)
        {
            usersQuery = usersQuery.Where(u => u.Role != null &&
                u.Role.Name != "Admin" &&
                u.Role.Name != "Manager");
        }

        var users = await usersQuery
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => MapUserResponse(x))
            .ToListAsync();

        return ServiceResponse<List<UserResponse>>.Success(users, "OK");
    }

    public async Task<ServiceResponse<UserResponse>> GetByIdAsync(string actorUserId, string userId)
    {
        var actor = await GetActorAsync(actorUserId);
        if (actor is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<UserResponse>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users
            .AsNoTracking()
            .Include(x => x.Role)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (user is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var access = EnsureActorCanManageUser(actor, user);
        if (access is not null)
        {
            return access;
        }

        return ServiceResponse<UserResponse>.Success(MapUserResponse(user), "OK");
    }

    public async Task<ServiceResponse<UserResponse>> GetMeAsync(string userId)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["User id is required"]);
        }

        var user = await dbContext.Users
            .AsNoTracking()
            .Include(x => x.Role)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (user is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        return ServiceResponse<UserResponse>.Success(MapUserResponse(user), "OK");
    }

    public async Task<ServiceResponse<UserResponse>> CreateAsync(string actorUserId, CreateUserRequest request)
    {
        var actor = await GetActorAsync(actorUserId);
        if (actor is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

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

        if (!actor.IsAdmin && IsPrivilegedRole(role.Name))
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Managers can only create Annotator or Reviewer accounts"]);
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

    public async Task<ServiceResponse<UserResponse>> UpdateAsync(string actorUserId, string userId, UpdateUserRequest request)
    {
        var actor = await GetActorAsync(actorUserId);
        if (actor is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<UserResponse>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users.Include(x => x.Role).FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var access = EnsureActorCanManageUser(actor, user);
        if (access is not null)
        {
            return access;
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

        /*if (!actor.IsAdmin && IsPrivilegedRole(role.Name))
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Managers can only assign Annotator or Reviewer roles"]);
        }*/

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

    public async Task<ServiceResponse<UserResponse>> UpdateMeAsync(string userId, UpdateOwnProfileRequest request)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["User id is required"]);
        }

        var user = await dbContext.Users.Include(x => x.Role).FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<UserResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var normalizedEmail = NormalizeEmail(request.Email);
        if (!string.Equals(user.Email, normalizedEmail, StringComparison.Ordinal))
        {
            var emailExists = await dbContext.Users.AsNoTracking()
                .AnyAsync(x => x.Email == normalizedEmail && x.Id != user.Id);
            if (emailExists)
            {
                return ServiceResponse<UserResponse>.Failure("Email already exists", ["Email is already registered"]);
            }

            user.Email = normalizedEmail;
        }

        user.FullName = request.FullName.Trim();
        user.PhoneNumber = string.IsNullOrWhiteSpace(request.PhoneNumber) ? null : request.PhoneNumber.Trim();
        user.IdentifyNumber = string.IsNullOrWhiteSpace(request.IdentifyNumber) ? null : request.IdentifyNumber.Trim();
        user.Gender = string.IsNullOrWhiteSpace(request.Gender) ? null : request.Gender.Trim();
        user.Address = string.IsNullOrWhiteSpace(request.Address) ? null : request.Address.Trim();
        user.DateOfBirth = request.DateOfBirth;

        await dbContext.SaveChangesAsync();

        return ServiceResponse<UserResponse>.Success(MapUserResponse(user), "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteAsync(string actorUserId, string userId)
    {
        var actor = await GetActorAsync(actorUserId);
        if (actor is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid user", ["User id is required"]);
        }

        if (string.Equals(actor.UserId, id, StringComparison.Ordinal))
        {
            return ServiceResponse<bool>.Failure("Invalid operation", ["You cannot delete your own account"]);
        }

        var user = await dbContext.Users.Include(x => x.Role).FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var access = EnsureActorCanManageUser(actor, user);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        dbContext.Users.Remove(user);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Deleted");
    }

    public async Task<ServiceResponse<bool>> DeleteMeAsync(string userId)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["User id is required"]);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var refreshTokens = await dbContext.RefreshTokens.Where(x => x.UserId == id).ToListAsync();
        dbContext.RefreshTokens.RemoveRange(refreshTokens);

        var passwordResets = await dbContext.PasswordResetTokens.Where(x => x.UserId == id).ToListAsync();
        dbContext.PasswordResetTokens.RemoveRange(passwordResets);

        var otps = await dbContext.EmailVerificationOtps.Where(x => x.UserId == id).ToListAsync();
        dbContext.EmailVerificationOtps.RemoveRange(otps);

        var projectRoles = await dbContext.UserProjectRoles.Where(x => x.UserId == id).ToListAsync();
        dbContext.UserProjectRoles.RemoveRange(projectRoles);

        dbContext.Users.Remove(user);

        try
        {
            await dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            return ServiceResponse<bool>.Failure(
                "Cannot delete account",
                ["Your account is linked to project data and cannot be deleted automatically. Contact an administrator."]);
        }

        return ServiceResponse<bool>.Success(true, "Deleted");
    }

    public async Task<ServiceResponse<List<UserSummaryResponse>>> SearchAsync(string actorUserId, string query, string? roleName = null)
    {
        var actor = await GetActorAsync(actorUserId);
        if (actor is null)
        {
            return ServiceResponse<List<UserSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var normalizedQuery = (query ?? string.Empty).Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(normalizedQuery))
        {
            return ServiceResponse<List<UserSummaryResponse>>.Success([], "OK");
        }

        var usersQuery = dbContext.Users
            .AsNoTracking()
            .Include(u => u.Role)
            .Where(u => u.Email.ToLower().Contains(normalizedQuery) || u.FullName.ToLower().Contains(normalizedQuery));

        if (!actor.IsAdmin)
        {
            usersQuery = usersQuery.Where(u => u.Role != null &&
                u.Role.Name != "Admin" &&
                u.Role.Name != "Manager");
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

    private async Task<ActorContext?> GetActorAsync(string actorUserId)
    {
        var actor = await dbContext.Users
            .AsNoTracking()
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.Id == actorUserId);

        if (actor is null)
        {
            return null;
        }

        return new ActorContext(
            actor.Id,
            string.Equals(actor.Role?.Name, "Admin", StringComparison.OrdinalIgnoreCase));
    }

    private static ServiceResponse<UserResponse>? EnsureActorCanManageUser(ActorContext actor, User target)
    {
        if (actor.IsAdmin || target.Role is null)
        {
            return null;
        }

        if (IsPrivilegedRole(target.Role.Name))
        {
            return ServiceResponse<UserResponse>.Failure(
                ErrorMessages.Unauthorized,
                ["Managers cannot manage Admin or Manager accounts"]);
        }

        return null;
    }

    private static bool IsPrivilegedRole(string? roleName)
        => string.Equals(roleName, "Admin", StringComparison.OrdinalIgnoreCase)
           || string.Equals(roleName, "Manager", StringComparison.OrdinalIgnoreCase);

    private static UserResponse MapUserResponse(User user)
        => new(
            user.Id,
            user.FullName,
            user.Email,
            user.PhoneNumber,
            user.IdentifyNumber,
            user.Gender,
            user.Address,
            user.DateOfBirth,
            user.RoleId,
            user.Role?.Name,
            user.Status,
            user.CreatedAt,
            user.UpdatedAt);

    private static string NormalizeEmail(string email) => (email ?? string.Empty).Trim().ToLowerInvariant();

    private sealed record ActorContext(string UserId, bool IsAdmin);
}

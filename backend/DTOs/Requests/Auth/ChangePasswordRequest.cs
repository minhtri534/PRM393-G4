namespace DataLabellingSupportSystem.Api.DTOs.Requests.Auth;

public sealed record ChangePasswordRequest(string CurrentPassword, string NewPassword);

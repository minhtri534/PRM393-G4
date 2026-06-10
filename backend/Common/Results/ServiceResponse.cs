namespace DataLabellingSupportSystem.Api.Common.Results;

public class ServiceResponse<T>
{
    public bool IsSuccess { get; set; }
    public T? Data { get; set; }
    public string Message { get; set; } = string.Empty;
    public List<string> Errors { get; set; } = [];

    public static ServiceResponse<T> Success(T data, string message = "Success")
    {
        return new ServiceResponse<T>
        {
            IsSuccess = true,
            Data = data,
            Message = message
        };
    }

    public static ServiceResponse<T> Failure(string message, List<string>? errors = null)
    {
        return new ServiceResponse<T>
        {
            IsSuccess = false,
            Message = message,
            Errors = errors ?? []
        };
    }
}

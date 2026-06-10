namespace DataLabellingSupportSystem.Api.Services.Storage;

public interface IStorageService
{
    Task<bool> SaveAsync(string storageProvider, string objectKey, Stream content, CancellationToken cancellationToken);
    Task<(Stream Stream, string ContentType, string FileName)?> OpenReadAsync(string storageProvider, string objectKey, CancellationToken cancellationToken);
}

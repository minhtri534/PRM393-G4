using DataLabellingSupportSystem.Api.Configurations;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Storage;

public sealed class LocalStorageService(IHostEnvironment env, IOptions<StorageOptions> options) : IStorageService
{
    private static readonly HttpClient HttpClient = new();
    private readonly StorageOptions _options = options.Value;
    private readonly FileExtensionContentTypeProvider _contentTypeProvider = new();

    public async Task<bool> SaveAsync(
        string storageProvider,
        string objectKey,
        Stream content,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(storageProvider, "Local", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var key = (objectKey ?? string.Empty).Trim().Replace('\\', '/');
        if (string.IsNullOrWhiteSpace(key))
        {
            return false;
        }

        var root = _options.LocalRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = "storage";
        }

        var rootPath = Path.IsPathRooted(root)
            ? root
            : Path.Combine(env.ContentRootPath, root);

        var fullPath = Path.GetFullPath(Path.Combine(rootPath, key));
        var normalizedRoot = Path.GetFullPath(rootPath);

        if (!fullPath.StartsWith(normalizedRoot, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var dir = Path.GetDirectoryName(fullPath);
        if (!string.IsNullOrWhiteSpace(dir))
        {
            Directory.CreateDirectory(dir);
        }

        if (content.CanSeek)
        {
            content.Position = 0;
        }

        await using var fileStream = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None);
        await content.CopyToAsync(fileStream, cancellationToken);
        await fileStream.FlushAsync(cancellationToken);
        return true;
    }

    public Task<(Stream Stream, string ContentType, string FileName)?> OpenReadAsync(
        string storageProvider,
        string objectKey,
        CancellationToken cancellationToken)
    {
        if (TryGetHttpUri(objectKey, out var remoteUri))
        {
            return OpenRemoteAsync(remoteUri, cancellationToken);
        }

        if (!string.Equals(storageProvider, "Local", StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult<(Stream, string, string)?>(null);
        }

        var key = (objectKey ?? string.Empty).Trim().Replace('\\', '/');
        if (string.IsNullOrWhiteSpace(key))
        {
            return Task.FromResult<(Stream, string, string)?>(null);
        }

        var root = _options.LocalRootPath;
        if (string.IsNullOrWhiteSpace(root))
        {
            root = "storage";
        }

        var rootPath = Path.IsPathRooted(root)
            ? root
            : Path.Combine(env.ContentRootPath, root);

        var fullPath = Path.GetFullPath(Path.Combine(rootPath, key));
        var normalizedRoot = Path.GetFullPath(rootPath);

        // Prevent path traversal by ensuring fullPath stays under rootPath
        if (!fullPath.StartsWith(normalizedRoot, StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult<(Stream, string, string)?>(null);
        }

        if (!File.Exists(fullPath))
        {
            return Task.FromResult<(Stream, string, string)?>(null);
        }

        var fileName = Path.GetFileName(fullPath);
        var contentType = _contentTypeProvider.TryGetContentType(fullPath, out var ct)
            ? ct
            : "application/octet-stream";

        Stream stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read, FileShare.Read);
        return Task.FromResult<(Stream, string, string)?>(new(stream, contentType, fileName));
    }

    private static async Task<(Stream Stream, string ContentType, string FileName)?> OpenRemoteAsync(Uri uri, CancellationToken cancellationToken)
    {
        using var response = await HttpClient.GetAsync(uri, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            return null;
        }

        await using var networkStream = await response.Content.ReadAsStreamAsync(cancellationToken);
        var buffer = new MemoryStream();
        await networkStream.CopyToAsync(buffer, cancellationToken);
        buffer.Position = 0;

        var contentType = response.Content.Headers.ContentType?.MediaType;
        if (string.IsNullOrWhiteSpace(contentType))
        {
            contentType = "application/octet-stream";
        }

        var fileName = Path.GetFileName(uri.LocalPath);
        if (string.IsNullOrWhiteSpace(fileName))
        {
            fileName = "download.bin";
        }

        return (buffer, contentType, fileName);
    }

    private static bool TryGetHttpUri(string value, out Uri uri)
    {
        var raw = (value ?? string.Empty).Trim();
        if (!Uri.TryCreate(raw, UriKind.Absolute, out uri!))
        {
            return false;
        }

        return uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps;
    }
}

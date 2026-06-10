using System.Text.Json;
using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Configurations;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.Services.Annotator;
using DataLabellingSupportSystem.Api.Services.Storage;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.AiAssist;

public interface IAiAssistService
{
    Task<ServiceResponse<AiAssistSuggestResponse>> SuggestBboxAsync(
        string userId,
        string taskId,
        bool applyAsDraft,
    string? labelId,
        CancellationToken cancellationToken);
}

public sealed class AiAssistService(
    AppDbContext dbContext,
    IStorageService storageService,
    IYoloInferenceClient yoloClient,
    IOptions<AiAssistOptions> options,
    IAnnotatorService annotatorService,
    ILogger<AiAssistService> logger) : IAiAssistService
{
    public async Task<ServiceResponse<AiAssistSuggestResponse>> SuggestBboxAsync(
        string userId,
        string taskId,
        bool applyAsDraft,
        string? labelId,
        CancellationToken cancellationToken)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();
        var selectedLabelId = (labelId ?? string.Empty).Trim();

        var opt = options.Value;
        if (!opt.Enabled)
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(
                "AI assist is disabled",
                ["Set AiAssist:Enabled=true in appsettings.Development.json (and configure BaseUrl to the YOLO service)"]);
        }

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure("Invalid task", ["Task id is required"]);
        }

        var item = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new
            {
                TaskId = x.Id,
                AnnotatorId = x.AnnotatorId,
                ProjectId = x.ProjectId,
                DataItemId = x.DataItemId,
                StorageProvider = x.DataItem != null ? x.DataItem.StorageProvider : null,
                ObjectKey = x.DataItem != null ? x.DataItem.ObjectKey : null,
                OriginalWidth = x.DataItem != null ? x.DataItem.OriginalWidth : 0,
                OriginalHeight = x.DataItem != null ? x.DataItem.OriginalHeight : 0
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (item is null)
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(item.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        if (string.IsNullOrWhiteSpace(item.ProjectId))
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.InternalServerError, ["Missing project id"]);
        }

        if (string.IsNullOrWhiteSpace(item.StorageProvider) || string.IsNullOrWhiteSpace(item.ObjectKey))
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.NotFound, ["Data item storage not found"]);
        }

        var labels = await dbContext.Labels
            .AsNoTracking()
            .Where(x => x.ProjectId == item.ProjectId)
            .Select(x => new { x.Id, x.YoloClassId })
            .ToListAsync(cancellationToken);

        var labelByClassId = labels
            .GroupBy(x => x.YoloClassId)
            .ToDictionary(g => g.Key, g => g.First().Id);

        HashSet<int>? allowedClassIds = null;
        if (!string.IsNullOrWhiteSpace(selectedLabelId))
        {
            var selectedLabel = labels.FirstOrDefault(x => string.Equals(x.Id, selectedLabelId, StringComparison.Ordinal));
            if (selectedLabel is null)
            {
                return ServiceResponse<AiAssistSuggestResponse>.Failure("Invalid label", ["Selected label is not available in this task project"]);
            }

            allowedClassIds = [selectedLabel.YoloClassId];
        }

        var opened = await storageService.OpenReadAsync(item.StorageProvider, item.ObjectKey, cancellationToken);
        if (opened is null)
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.NotFound, ["Image not found in storage"]);
        }

        await using var stream = opened.Value.Stream;
        using var ms = new MemoryStream();

        await stream.CopyToAsync(ms, cancellationToken);
        if (ms.Length > opt.MaxImageBytes)
        {
            return ServiceResponse<AiAssistSuggestResponse>.Failure(
                "Image too large",
                [$"MaxImageBytes exceeded: {ms.Length} > {opt.MaxImageBytes}"]);
        }

        var imageBytes = ms.ToArray();

        var runId = Guid.NewGuid().ToString("N");
        logger.LogInformation(
            "AI assist suggest started. RunId={RunId} TaskId={TaskId} Provider={Provider} Model={Model} ApplyAsDraft={ApplyAsDraft}",
            runId,
            id,
            opt.Provider,
            opt.Model,
            applyAsDraft);

        var detect = await yoloClient.DetectAsync(imageBytes, opened.Value.FileName, cancellationToken);

        var objects = new List<AiAssistSuggestionObject>();

        foreach (var det in detect.Detections)
        {
            if (allowedClassIds is not null && !allowedClassIds.Contains(det.ClassId))
            {
                continue;
            }

            if (!labelByClassId.TryGetValue(det.ClassId, out var mappedLabelId))
            {
                continue;
            }

            var x = Math.Max(0, det.X1);
            var y = Math.Max(0, det.Y1);
            var width = Math.Max(0, det.X2 - det.X1);
            var height = Math.Max(0, det.Y2 - det.Y1);

            if (width <= 0 || height <= 0)
            {
                continue;
            }

            var geometryJson = JsonSerializer.Serialize(new
            {
                type = "bbox",
                x,
                y,
                width,
                height
            });

            objects.Add(new AiAssistSuggestionObject(
                LabelId: mappedLabelId,
                Confidence: det.Confidence,
                GeometryData: geometryJson));
        }

        var prediction = new Models.AiPrediction
        {
            DataItemId = item.DataItemId,
            TaskId = item.TaskId,
            ModelName = $"{detect.Provider}:{detect.Model}",
            PredictionData = JsonSerializer.Serialize(new
            {
                taskId = item.TaskId,
                provider = detect.Provider,
                model = detect.Model,
                confidenceThreshold = detect.ConfidenceThreshold,
                objects
            }),
            Confidence = objects.Count == 0 ? 0 : (float)objects.Average(x => x.Confidence),
            IsAccepted = false,
            Decision = "Pending"
        };

        dbContext.AiPredictions.Add(prediction);
        await dbContext.SaveChangesAsync(cancellationToken);

        if (applyAsDraft)
        {
            var upsertObjects = new List<UpsertAnnotationObject>(objects.Count);
            foreach (var obj in objects)
            {
                using var jsonDoc = JsonDocument.Parse(obj.GeometryData);
                upsertObjects.Add(new UpsertAnnotationObject(obj.LabelId, jsonDoc.RootElement.Clone()));
            }

            var saveResult = await annotatorService.SaveTaskAnnotationsDraftAsync(
                uid,
                id,
                new UpsertTaskItemAnnotationsRequest(upsertObjects, PredictionId: prediction.Id));

            if (!saveResult.IsSuccess)
            {
                return ServiceResponse<AiAssistSuggestResponse>.Failure(
                    "AI suggest produced results but failed to save draft",
                    saveResult.Errors);
            }

        }

        var response = new AiAssistSuggestResponse(
            RunId: prediction.Id,
            Provider: detect.Provider,
            Model: detect.Model,
            ConfidenceThreshold: detect.ConfidenceThreshold,
            OriginalWidth: item.OriginalWidth,
            OriginalHeight: item.OriginalHeight,
            Objects: objects);

        logger.LogInformation(
            "AI assist suggest completed. RunId={RunId} Objects={Count}",
            runId,
            objects.Count);

        return ServiceResponse<AiAssistSuggestResponse>.Success(response, "OK");
    }
}

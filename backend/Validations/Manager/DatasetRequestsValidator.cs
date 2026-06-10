using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Manager;

public sealed class CreateDatasetRequestValidator : AbstractValidator<CreateDatasetRequest>
{
    public CreateDatasetRequestValidator()
    {
        RuleFor(x => x.ProjectId).NotEmpty().Length(24);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
    }
}

public sealed class UpdateDatasetRequestValidator : AbstractValidator<UpdateDatasetRequest>
{
    public UpdateDatasetRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
    }
}

public sealed class UploadDatasetItemsRequestValidator : AbstractValidator<UploadDatasetItemsRequest>
{
    public UploadDatasetItemsRequestValidator()
    {
        RuleFor(x => x.DatasetId).NotEmpty().Length(24);
        RuleFor(x => x.Items).NotEmpty();
        RuleForEach(x => x.Items).SetValidator(new UploadDatasetItemDtoValidator());
    }
}

public sealed class ImportDatasetFromExternalRequestValidator : AbstractValidator<ImportDatasetFromExternalRequest>
{
    public ImportDatasetFromExternalRequestValidator()
    {
        RuleFor(x => x.DatasetId).NotEmpty().Length(24);
        RuleFor(x => x.SourceName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Items).NotEmpty();
        RuleForEach(x => x.Items).SetValidator(new UploadDatasetItemDtoValidator());
    }
}

public sealed class UploadDatasetItemDtoValidator : AbstractValidator<UploadDatasetItemDto>
{
    public UploadDatasetItemDtoValidator()
    {
        RuleFor(x => x.ObjectKey).NotEmpty().MaximumLength(500);
        RuleFor(x => x.OriginalWidth).GreaterThanOrEqualTo(0);
        RuleFor(x => x.OriginalHeight).GreaterThanOrEqualTo(0);
        RuleFor(x => x.DataType).NotEmpty().MaximumLength(50);
        RuleFor(x => x.StorageProvider).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Checksum).MaximumLength(64);
    }
}

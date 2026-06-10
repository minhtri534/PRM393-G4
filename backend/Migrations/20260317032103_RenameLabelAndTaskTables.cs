using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class RenameLabelAndTaskTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Annotations_DataItems_dataItemId",
                table: "Annotations");

            migrationBuilder.DropForeignKey(
                name: "FK_Annotations_Labels_labelId",
                table: "Annotations");

            migrationBuilder.DropForeignKey(
                name: "FK_Annotations_TaskItems_taskItemId",
                table: "Annotations");

            migrationBuilder.DropForeignKey(
                name: "FK_Annotations_Users_createdBy",
                table: "Annotations");

            migrationBuilder.DropForeignKey(
                name: "FK_Labels_Projects_projectId",
                table: "Labels");

            migrationBuilder.DropForeignKey(
                name: "FK_Tasks_Datasets_datasetId",
                table: "Tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_Tasks_Projects_projectId",
                table: "Tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_Tasks_Users_assignedToUserId",
                table: "Tasks");

            migrationBuilder.DropTable(
                name: "TaskItems");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Tasks",
                table: "Tasks");

            migrationBuilder.DropIndex(
                name: "IX_Annotations_createdBy",
                table: "Annotations");

            migrationBuilder.DropIndex(
                name: "IX_Annotations_dataItemId",
                table: "Annotations");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Labels",
                table: "Labels");

            migrationBuilder.DropColumn(
                name: "createdAt",
                table: "Tasks");

            migrationBuilder.DropColumn(
                name: "dueAt",
                table: "Tasks");

            migrationBuilder.DropColumn(
                name: "name",
                table: "Tasks");

            migrationBuilder.DropColumn(
                name: "startedAt",
                table: "Tasks");

            migrationBuilder.DropColumn(
                name: "updatedAt",
                table: "Tasks");

            migrationBuilder.DropColumn(
                name: "createdBy",
                table: "Annotations");

            migrationBuilder.DropColumn(
                name: "dataItemId",
                table: "Annotations");

            migrationBuilder.DropColumn(
                name: "isDraft",
                table: "Annotations");

            migrationBuilder.DropColumn(
                name: "submittedAt",
                table: "Annotations");

            migrationBuilder.RenameTable(
                name: "Tasks",
                newName: "tasks");

            migrationBuilder.RenameTable(
                name: "Labels",
                newName: "label_classes");

            migrationBuilder.RenameColumn(
                name: "submittedAt",
                table: "tasks",
                newName: "completedAt");

            migrationBuilder.RenameColumn(
                name: "datasetId",
                table: "tasks",
                newName: "assignedBy");

            migrationBuilder.RenameColumn(
                name: "assignedToUserId",
                table: "tasks",
                newName: "dataItemId");

            migrationBuilder.RenameIndex(
                name: "IX_Tasks_projectId",
                table: "tasks",
                newName: "IX_tasks_projectId");

            migrationBuilder.RenameIndex(
                name: "IX_Tasks_datasetId",
                table: "tasks",
                newName: "IX_tasks_assignedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Tasks_assignedToUserId",
                table: "tasks",
                newName: "IX_tasks_dataItemId");

            migrationBuilder.RenameColumn(
                name: "originalWidth",
                table: "DataItems",
                newName: "width");

            migrationBuilder.RenameColumn(
                name: "originalHeight",
                table: "DataItems",
                newName: "height");

            migrationBuilder.RenameColumn(
                name: "objectKey",
                table: "DataItems",
                newName: "filePath");

            migrationBuilder.RenameColumn(
                name: "taskItemId",
                table: "Annotations",
                newName: "annotationSetId");

            migrationBuilder.RenameIndex(
                name: "IX_Annotations_taskItemId",
                table: "Annotations",
                newName: "IX_Annotations_annotationSetId");

            migrationBuilder.RenameIndex(
                name: "IX_Labels_projectId_yoloClassId",
                table: "label_classes",
                newName: "IX_label_classes_projectId_yoloClassId");

            migrationBuilder.RenameIndex(
                name: "IX_Labels_projectId_name",
                table: "label_classes",
                newName: "IX_label_classes_projectId_name");

            migrationBuilder.AlterColumn<string>(
                name: "status",
                table: "tasks",
                type: "varchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Assigned",
                oldClrType: typeof(int),
                oldType: "int",
                oldDefaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "annotatorId",
                table: "tasks",
                type: "varchar(24)",
                maxLength: 24,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "checksum",
                table: "DataItems",
                type: "varchar(64)",
                maxLength: 64,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "dataType",
                table: "DataItems",
                type: "varchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "Image");

            migrationBuilder.AddColumn<string>(
                name: "status",
                table: "DataItems",
                type: "varchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Active");

            migrationBuilder.AddColumn<string>(
                name: "uploadedBy",
                table: "DataItems",
                type: "varchar(24)",
                maxLength: 24,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "annotationType",
                table: "Annotations",
                type: "varchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "version",
                table: "Annotations",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddPrimaryKey(
                name: "PK_tasks",
                table: "tasks",
                column: "_id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_label_classes",
                table: "label_classes",
                column: "_id");

            migrationBuilder.CreateTable(
                name: "AiPredictions",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(24)", maxLength: 24, nullable: false),
                    DataItemId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    ModelName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PredictionData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Confidence = table.Column<float>(type: "real", nullable: false),
                    IsAccepted = table.Column<bool>(type: "bit", nullable: false),
                    AcceptedByUserId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: true),
                    AcceptedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AiPredictions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AiPredictions_DataItems_DataItemId",
                        column: x => x.DataItemId,
                        principalTable: "DataItems",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AiPredictions_Users_AcceptedByUserId",
                        column: x => x.AcceptedByUserId,
                        principalTable: "Users",
                        principalColumn: "_id");
                });

            migrationBuilder.CreateTable(
                name: "AnnotationSets",
                columns: table => new
                {
                    Id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    TaskId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    CreatedByUserId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AnnotationSets", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AnnotationSets_Users_CreatedByUserId",
                        column: x => x.CreatedByUserId,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AnnotationSets_tasks_TaskId",
                        column: x => x.TaskId,
                        principalTable: "tasks",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ErrorTypes",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(24)", maxLength: 24, nullable: false),
                    ErrorName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ErrorTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TaskHistories",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(24)", maxLength: 24, nullable: false),
                    TaskId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    OldStatus = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    NewStatus = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ChangedByUserId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    ChangedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaskHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TaskHistories_Users_ChangedByUserId",
                        column: x => x.ChangedByUserId,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TaskHistories_tasks_TaskId",
                        column: x => x.TaskId,
                        principalTable: "tasks",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(24)", maxLength: 24, nullable: false),
                    AnnotationSetId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    ReviewerId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    Result = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Score = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ReviewedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_AnnotationSets_AnnotationSetId",
                        column: x => x.AnnotationSetId,
                        principalTable: "AnnotationSets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reviews_Users_ReviewerId",
                        column: x => x.ReviewerId,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "ReviewErrors",
                columns: table => new
                {
                    ReviewId = table.Column<string>(type: "nvarchar(24)", maxLength: 24, nullable: false),
                    ErrorTypeId = table.Column<string>(type: "nvarchar(24)", maxLength: 24, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReviewErrors", x => new { x.ReviewId, x.ErrorTypeId });
                    table.ForeignKey(
                        name: "FK_ReviewErrors_ErrorTypes_ErrorTypeId",
                        column: x => x.ErrorTypeId,
                        principalTable: "ErrorTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ReviewErrors_Reviews_ReviewId",
                        column: x => x.ReviewId,
                        principalTable: "Reviews",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_tasks_annotatorId",
                table: "tasks",
                column: "annotatorId");

            migrationBuilder.CreateIndex(
                name: "IX_DataItems_uploadedBy",
                table: "DataItems",
                column: "uploadedBy");

            migrationBuilder.CreateIndex(
                name: "IX_AiPredictions_AcceptedByUserId",
                table: "AiPredictions",
                column: "AcceptedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_AiPredictions_DataItemId",
                table: "AiPredictions",
                column: "DataItemId");

            migrationBuilder.CreateIndex(
                name: "IX_AnnotationSets_CreatedByUserId",
                table: "AnnotationSets",
                column: "CreatedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_AnnotationSets_TaskId",
                table: "AnnotationSets",
                column: "TaskId");

            migrationBuilder.CreateIndex(
                name: "IX_ReviewErrors_ErrorTypeId",
                table: "ReviewErrors",
                column: "ErrorTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_AnnotationSetId",
                table: "Reviews",
                column: "AnnotationSetId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_ReviewerId",
                table: "Reviews",
                column: "ReviewerId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskHistories_ChangedByUserId",
                table: "TaskHistories",
                column: "ChangedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskHistories_TaskId",
                table: "TaskHistories",
                column: "TaskId");

            migrationBuilder.AddForeignKey(
                name: "FK_Annotations_AnnotationSets_annotationSetId",
                table: "Annotations",
                column: "annotationSetId",
                principalTable: "AnnotationSets",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Annotations_label_classes_labelId",
                table: "Annotations",
                column: "labelId",
                principalTable: "label_classes",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_DataItems_Users_uploadedBy",
                table: "DataItems",
                column: "uploadedBy",
                principalTable: "Users",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_label_classes_Projects_projectId",
                table: "label_classes",
                column: "projectId",
                principalTable: "Projects",
                principalColumn: "_id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_tasks_DataItems_dataItemId",
                table: "tasks",
                column: "dataItemId",
                principalTable: "DataItems",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tasks_Projects_projectId",
                table: "tasks",
                column: "projectId",
                principalTable: "Projects",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tasks_Users_annotatorId",
                table: "tasks",
                column: "annotatorId",
                principalTable: "Users",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_tasks_Users_assignedBy",
                table: "tasks",
                column: "assignedBy",
                principalTable: "Users",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Annotations_AnnotationSets_annotationSetId",
                table: "Annotations");

            migrationBuilder.DropForeignKey(
                name: "FK_Annotations_label_classes_labelId",
                table: "Annotations");

            migrationBuilder.DropForeignKey(
                name: "FK_DataItems_Users_uploadedBy",
                table: "DataItems");

            migrationBuilder.DropForeignKey(
                name: "FK_label_classes_Projects_projectId",
                table: "label_classes");

            migrationBuilder.DropForeignKey(
                name: "FK_tasks_DataItems_dataItemId",
                table: "tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_tasks_Projects_projectId",
                table: "tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_tasks_Users_annotatorId",
                table: "tasks");

            migrationBuilder.DropForeignKey(
                name: "FK_tasks_Users_assignedBy",
                table: "tasks");

            migrationBuilder.DropTable(
                name: "AiPredictions");

            migrationBuilder.DropTable(
                name: "ReviewErrors");

            migrationBuilder.DropTable(
                name: "TaskHistories");

            migrationBuilder.DropTable(
                name: "ErrorTypes");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "AnnotationSets");

            migrationBuilder.DropPrimaryKey(
                name: "PK_tasks",
                table: "tasks");

            migrationBuilder.DropIndex(
                name: "IX_tasks_annotatorId",
                table: "tasks");

            migrationBuilder.DropIndex(
                name: "IX_DataItems_uploadedBy",
                table: "DataItems");

            migrationBuilder.DropPrimaryKey(
                name: "PK_label_classes",
                table: "label_classes");

            migrationBuilder.DropColumn(
                name: "annotatorId",
                table: "tasks");

            migrationBuilder.DropColumn(
                name: "checksum",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "dataType",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "status",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "uploadedBy",
                table: "DataItems");

            migrationBuilder.DropColumn(
                name: "annotationType",
                table: "Annotations");

            migrationBuilder.DropColumn(
                name: "version",
                table: "Annotations");

            migrationBuilder.RenameTable(
                name: "tasks",
                newName: "Tasks");

            migrationBuilder.RenameTable(
                name: "label_classes",
                newName: "Labels");

            migrationBuilder.RenameColumn(
                name: "dataItemId",
                table: "Tasks",
                newName: "assignedToUserId");

            migrationBuilder.RenameColumn(
                name: "completedAt",
                table: "Tasks",
                newName: "submittedAt");

            migrationBuilder.RenameColumn(
                name: "assignedBy",
                table: "Tasks",
                newName: "datasetId");

            migrationBuilder.RenameIndex(
                name: "IX_tasks_projectId",
                table: "Tasks",
                newName: "IX_Tasks_projectId");

            migrationBuilder.RenameIndex(
                name: "IX_tasks_dataItemId",
                table: "Tasks",
                newName: "IX_Tasks_assignedToUserId");

            migrationBuilder.RenameIndex(
                name: "IX_tasks_assignedBy",
                table: "Tasks",
                newName: "IX_Tasks_datasetId");

            migrationBuilder.RenameColumn(
                name: "width",
                table: "DataItems",
                newName: "originalWidth");

            migrationBuilder.RenameColumn(
                name: "height",
                table: "DataItems",
                newName: "originalHeight");

            migrationBuilder.RenameColumn(
                name: "filePath",
                table: "DataItems",
                newName: "objectKey");

            migrationBuilder.RenameColumn(
                name: "annotationSetId",
                table: "Annotations",
                newName: "taskItemId");

            migrationBuilder.RenameIndex(
                name: "IX_Annotations_annotationSetId",
                table: "Annotations",
                newName: "IX_Annotations_taskItemId");

            migrationBuilder.RenameIndex(
                name: "IX_label_classes_projectId_yoloClassId",
                table: "Labels",
                newName: "IX_Labels_projectId_yoloClassId");

            migrationBuilder.RenameIndex(
                name: "IX_label_classes_projectId_name",
                table: "Labels",
                newName: "IX_Labels_projectId_name");

            migrationBuilder.AlterColumn<int>(
                name: "status",
                table: "Tasks",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldMaxLength: 20,
                oldDefaultValue: "Assigned");

            migrationBuilder.AddColumn<DateTime>(
                name: "createdAt",
                table: "Tasks",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AddColumn<DateTime>(
                name: "dueAt",
                table: "Tasks",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "name",
                table: "Tasks",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "startedAt",
                table: "Tasks",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updatedAt",
                table: "Tasks",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AddColumn<string>(
                name: "createdBy",
                table: "Annotations",
                type: "varchar(24)",
                maxLength: 24,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "dataItemId",
                table: "Annotations",
                type: "varchar(24)",
                maxLength: 24,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "isDraft",
                table: "Annotations",
                type: "bit",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "submittedAt",
                table: "Annotations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Tasks",
                table: "Tasks",
                column: "_id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Labels",
                table: "Labels",
                column: "_id");

            migrationBuilder.CreateTable(
                name: "TaskItems",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    dataItemId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    taskId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    lastSavedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    orderIndex = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    status = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaskItems", x => x._id);
                    table.ForeignKey(
                        name: "FK_TaskItems_DataItems_dataItemId",
                        column: x => x.dataItemId,
                        principalTable: "DataItems",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TaskItems_Tasks_taskId",
                        column: x => x.taskId,
                        principalTable: "Tasks",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Annotations_createdBy",
                table: "Annotations",
                column: "createdBy");

            migrationBuilder.CreateIndex(
                name: "IX_Annotations_dataItemId",
                table: "Annotations",
                column: "dataItemId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskItems_dataItemId",
                table: "TaskItems",
                column: "dataItemId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskItems_taskId_orderIndex",
                table: "TaskItems",
                columns: new[] { "taskId", "orderIndex" });

            migrationBuilder.AddForeignKey(
                name: "FK_Annotations_DataItems_dataItemId",
                table: "Annotations",
                column: "dataItemId",
                principalTable: "DataItems",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Annotations_Labels_labelId",
                table: "Annotations",
                column: "labelId",
                principalTable: "Labels",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Annotations_TaskItems_taskItemId",
                table: "Annotations",
                column: "taskItemId",
                principalTable: "TaskItems",
                principalColumn: "_id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Annotations_Users_createdBy",
                table: "Annotations",
                column: "createdBy",
                principalTable: "Users",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Labels_Projects_projectId",
                table: "Labels",
                column: "projectId",
                principalTable: "Projects",
                principalColumn: "_id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Tasks_Datasets_datasetId",
                table: "Tasks",
                column: "datasetId",
                principalTable: "Datasets",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Tasks_Projects_projectId",
                table: "Tasks",
                column: "projectId",
                principalTable: "Projects",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Tasks_Users_assignedToUserId",
                table: "Tasks",
                column: "assignedToUserId",
                principalTable: "Users",
                principalColumn: "_id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}

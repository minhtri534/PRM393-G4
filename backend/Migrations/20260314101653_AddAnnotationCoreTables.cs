using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddAnnotationCoreTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Projects",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    status = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Projects", x => x._id);
                });

            migrationBuilder.CreateTable(
                name: "Datasets",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    projectId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Datasets", x => x._id);
                    table.ForeignKey(
                        name: "FK_Datasets_Projects_projectId",
                        column: x => x.projectId,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Labels",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    projectId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    yoloClassId = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Labels", x => x._id);
                    table.ForeignKey(
                        name: "FK_Labels_Projects_projectId",
                        column: x => x.projectId,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "DataItems",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    datasetId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    storageProvider = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    objectKey = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    originalWidth = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    originalHeight = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DataItems", x => x._id);
                    table.ForeignKey(
                        name: "FK_DataItems_Datasets_datasetId",
                        column: x => x.datasetId,
                        principalTable: "Datasets",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Tasks",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    projectId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    datasetId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: true),
                    name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    assignedToUserId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    status = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    assignedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    startedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    submittedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    dueAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tasks", x => x._id);
                    table.ForeignKey(
                        name: "FK_Tasks_Datasets_datasetId",
                        column: x => x.datasetId,
                        principalTable: "Datasets",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Tasks_Projects_projectId",
                        column: x => x.projectId,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Tasks_Users_assignedToUserId",
                        column: x => x.assignedToUserId,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TaskItems",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    taskId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    dataItemId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    status = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    lastSavedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    orderIndex = table.Column<int>(type: "int", nullable: false, defaultValue: 0)
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

            migrationBuilder.CreateTable(
                name: "Annotations",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    taskItemId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    dataItemId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    labelId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    geometryData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    createdBy = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    isDraft = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    submittedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Annotations", x => x._id);
                    table.ForeignKey(
                        name: "FK_Annotations_DataItems_dataItemId",
                        column: x => x.dataItemId,
                        principalTable: "DataItems",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Annotations_Labels_labelId",
                        column: x => x.labelId,
                        principalTable: "Labels",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Annotations_TaskItems_taskItemId",
                        column: x => x.taskItemId,
                        principalTable: "TaskItems",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Annotations_Users_createdBy",
                        column: x => x.createdBy,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
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
                name: "IX_Annotations_labelId",
                table: "Annotations",
                column: "labelId");

            migrationBuilder.CreateIndex(
                name: "IX_Annotations_taskItemId",
                table: "Annotations",
                column: "taskItemId");

            migrationBuilder.CreateIndex(
                name: "IX_DataItems_datasetId",
                table: "DataItems",
                column: "datasetId");

            migrationBuilder.CreateIndex(
                name: "IX_Datasets_projectId",
                table: "Datasets",
                column: "projectId");

            migrationBuilder.CreateIndex(
                name: "IX_Labels_projectId_name",
                table: "Labels",
                columns: new[] { "projectId", "name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Labels_projectId_yoloClassId",
                table: "Labels",
                columns: new[] { "projectId", "yoloClassId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TaskItems_dataItemId",
                table: "TaskItems",
                column: "dataItemId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskItems_taskId_orderIndex",
                table: "TaskItems",
                columns: new[] { "taskId", "orderIndex" });

            migrationBuilder.CreateIndex(
                name: "IX_Tasks_assignedToUserId",
                table: "Tasks",
                column: "assignedToUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Tasks_datasetId",
                table: "Tasks",
                column: "datasetId");

            migrationBuilder.CreateIndex(
                name: "IX_Tasks_projectId",
                table: "Tasks",
                column: "projectId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Annotations");

            migrationBuilder.DropTable(
                name: "Labels");

            migrationBuilder.DropTable(
                name: "TaskItems");

            migrationBuilder.DropTable(
                name: "DataItems");

            migrationBuilder.DropTable(
                name: "Tasks");

            migrationBuilder.DropTable(
                name: "Datasets");

            migrationBuilder.DropTable(
                name: "Projects");
        }
    }
}

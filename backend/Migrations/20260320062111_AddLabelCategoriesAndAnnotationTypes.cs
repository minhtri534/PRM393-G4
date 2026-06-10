using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddLabelCategoriesAndAnnotationTypes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "annotationTypeId",
                table: "label_classes",
                type: "varchar(24)",
                maxLength: 24,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "categoryId",
                table: "label_classes",
                type: "varchar(24)",
                maxLength: 24,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "annotation_types",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    projectId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    name = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_annotation_types", x => x._id);
                    table.ForeignKey(
                        name: "FK_annotation_types_Projects_projectId",
                        column: x => x.projectId,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "label_categories",
                columns: table => new
                {
                    _id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    projectId = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    name = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    createdAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())"),
                    updatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_label_categories", x => x._id);
                    table.ForeignKey(
                        name: "FK_label_categories_Projects_projectId",
                        column: x => x.projectId,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_label_classes_annotationTypeId",
                table: "label_classes",
                column: "annotationTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_label_classes_categoryId",
                table: "label_classes",
                column: "categoryId");

            migrationBuilder.CreateIndex(
                name: "IX_annotation_types_projectId_name",
                table: "annotation_types",
                columns: new[] { "projectId", "name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_label_categories_projectId_name",
                table: "label_categories",
                columns: new[] { "projectId", "name" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_label_classes_annotation_types_annotationTypeId",
                table: "label_classes",
                column: "annotationTypeId",
                principalTable: "annotation_types",
                principalColumn: "_id");

            migrationBuilder.AddForeignKey(
                name: "FK_label_classes_label_categories_categoryId",
                table: "label_classes",
                column: "categoryId",
                principalTable: "label_categories",
                principalColumn: "_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_label_classes_annotation_types_annotationTypeId",
                table: "label_classes");

            migrationBuilder.DropForeignKey(
                name: "FK_label_classes_label_categories_categoryId",
                table: "label_classes");

            migrationBuilder.DropTable(
                name: "annotation_types");

            migrationBuilder.DropTable(
                name: "label_categories");

            migrationBuilder.DropIndex(
                name: "IX_label_classes_annotationTypeId",
                table: "label_classes");

            migrationBuilder.DropIndex(
                name: "IX_label_classes_categoryId",
                table: "label_classes");

            migrationBuilder.DropColumn(
                name: "annotationTypeId",
                table: "label_classes");

            migrationBuilder.DropColumn(
                name: "categoryId",
                table: "label_classes");
        }
    }
}

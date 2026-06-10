using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class LinkAiPredictionsToAnnotationSets : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AppliedAnnotationSetId",
                table: "AiPredictions",
                type: "nvarchar(24)",
                maxLength: 24,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Decision",
                table: "AiPredictions",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TaskId",
                table: "AiPredictions",
                type: "nvarchar(24)",
                maxLength: 24,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AppliedAnnotationSetId",
                table: "AiPredictions");

            migrationBuilder.DropColumn(
                name: "Decision",
                table: "AiPredictions");

            migrationBuilder.DropColumn(
                name: "TaskId",
                table: "AiPredictions");
        }
    }
}

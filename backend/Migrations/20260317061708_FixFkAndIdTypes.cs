using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class FixFkAndIdTypes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "AnnotationSetId",
                table: "Reviews",
                type: "varchar(24)",
                maxLength: 24,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(24)",
                oldMaxLength: 24);

            migrationBuilder.AlterColumn<string>(
                name: "Id",
                table: "AnnotationSets",
                type: "varchar(24)",
                maxLength: 24,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(24)",
                oldMaxLength: 24);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "AnnotationSetId",
                table: "Reviews",
                type: "nvarchar(24)",
                maxLength: 24,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(24)",
                oldMaxLength: 24);

            migrationBuilder.AlterColumn<string>(
                name: "Id",
                table: "AnnotationSets",
                type: "nvarchar(24)",
                maxLength: 24,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(24)",
                oldMaxLength: 24);
        }
    }
}

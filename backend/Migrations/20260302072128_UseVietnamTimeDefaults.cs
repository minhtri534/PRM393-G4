using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class UseVietnamTimeDefaults : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<DateTime>(
                name: "updatedAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "SYSUTCDATETIME()");

            migrationBuilder.AlterColumn<DateTime>(
                name: "createdAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "SYSUTCDATETIME()");

            migrationBuilder.AlterColumn<DateTime>(
                name: "createdAt",
                table: "RefreshTokens",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "SYSUTCDATETIME()");

            migrationBuilder.AlterColumn<DateTime>(
                name: "createdAt",
                table: "PasswordResetTokens",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "SYSUTCDATETIME()");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<DateTime>(
                name: "updatedAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "SYSUTCDATETIME()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AlterColumn<DateTime>(
                name: "createdAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "SYSUTCDATETIME()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AlterColumn<DateTime>(
                name: "createdAt",
                table: "RefreshTokens",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "SYSUTCDATETIME()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");

            migrationBuilder.AlterColumn<DateTime>(
                name: "createdAt",
                table: "PasswordResetTokens",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "SYSUTCDATETIME()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())");
        }
    }
}

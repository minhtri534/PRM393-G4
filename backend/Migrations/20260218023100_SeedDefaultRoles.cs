using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class SeedDefaultRoles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE [_id] = '000000000000000000000001')
        INSERT INTO [dbo].[Roles] ([_id], [name]) VALUES ('000000000000000000000001', N'Admin');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE [_id] = '000000000000000000000002')
        INSERT INTO [dbo].[Roles] ([_id], [name]) VALUES ('000000000000000000000002', N'Manager');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE [_id] = '000000000000000000000003')
        INSERT INTO [dbo].[Roles] ([_id], [name]) VALUES ('000000000000000000000003', N'Annotator');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE [_id] = '000000000000000000000004')
        INSERT INTO [dbo].[Roles] ([_id], [name]) VALUES ('000000000000000000000004', N'Reviewer');
    ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
    DELETE FROM [dbo].[Roles] WHERE [_id] IN (
        '000000000000000000000001',
        '000000000000000000000002',
        '000000000000000000000003',
        '000000000000000000000004'
    );
    ");
        }
    }
}

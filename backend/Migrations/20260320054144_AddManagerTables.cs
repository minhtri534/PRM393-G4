using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddManagerTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "activity_logs",
                columns: table => new
                {
                    log_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    user_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    action = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: false),
                    target_type = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    target_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_activity_logs", x => x.log_id);
                    table.ForeignKey(
                        name: "FK_activity_logs_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "dataset_versions",
                columns: table => new
                {
                    version_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    dataset_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    version_name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_dataset_versions", x => x.version_id);
                    table.ForeignKey(
                        name: "FK_dataset_versions_Datasets_dataset_id",
                        column: x => x.dataset_id,
                        principalTable: "Datasets",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "exports",
                columns: table => new
                {
                    export_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    project_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    format = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    exported_by = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    export_path = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exports", x => x.export_id);
                    table.ForeignKey(
                        name: "FK_exports_Projects_project_id",
                        column: x => x.project_id,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_exports_Users_exported_by",
                        column: x => x.exported_by,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "user_project_roles",
                columns: table => new
                {
                    user_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    project_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    role_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_project_roles", x => new { x.user_id, x.project_id, x.role_id });
                    table.ForeignKey(
                        name: "FK_user_project_roles_Projects_project_id",
                        column: x => x.project_id,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_user_project_roles_Roles_role_id",
                        column: x => x.role_id,
                        principalTable: "Roles",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_user_project_roles_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "export_configs",
                columns: table => new
                {
                    export_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    label_format = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    include_fields = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    filters = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_export_configs", x => x.export_id);
                    table.ForeignKey(
                        name: "FK_export_configs_exports_export_id",
                        column: x => x.export_id,
                        principalTable: "exports",
                        principalColumn: "export_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_activity_logs_target_type_target_id",
                table: "activity_logs",
                columns: new[] { "target_type", "target_id" });

            migrationBuilder.CreateIndex(
                name: "IX_activity_logs_user_id",
                table: "activity_logs",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_dataset_versions_dataset_id_version_name",
                table: "dataset_versions",
                columns: new[] { "dataset_id", "version_name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_exports_exported_by",
                table: "exports",
                column: "exported_by");

            migrationBuilder.CreateIndex(
                name: "IX_exports_project_id",
                table: "exports",
                column: "project_id");

            migrationBuilder.CreateIndex(
                name: "IX_user_project_roles_project_id",
                table: "user_project_roles",
                column: "project_id");

            migrationBuilder.CreateIndex(
                name: "IX_user_project_roles_role_id",
                table: "user_project_roles",
                column: "role_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "activity_logs");

            migrationBuilder.DropTable(
                name: "dataset_versions");

            migrationBuilder.DropTable(
                name: "export_configs");

            migrationBuilder.DropTable(
                name: "user_project_roles");

            migrationBuilder.DropTable(
                name: "exports");
        }
    }
}

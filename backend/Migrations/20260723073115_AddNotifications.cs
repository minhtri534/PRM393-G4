using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddNotifications : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "notifications",
                columns: table => new
                {
                    notification_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    recipient_user_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    actor_user_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: true),
                    project_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: true),
                    type = table.Column<string>(type: "varchar(40)", maxLength: 40, nullable: false),
                    title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    body = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    related_entity_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: true),
                    is_read = table.Column<bool>(type: "bit", nullable: false, defaultValue: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_notifications", x => x.notification_id);
                    table.ForeignKey(
                        name: "FK_notifications_Projects_project_id",
                        column: x => x.project_id,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_notifications_Users_actor_user_id",
                        column: x => x.actor_user_id,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_notifications_Users_recipient_user_id",
                        column: x => x.recipient_user_id,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_notifications_actor_user_id",
                table: "notifications",
                column: "actor_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_notifications_project_id",
                table: "notifications",
                column: "project_id");

            migrationBuilder.CreateIndex(
                name: "IX_notifications_recipient_user_id_created_at",
                table: "notifications",
                columns: new[] { "recipient_user_id", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_notifications_recipient_user_id_is_read_created_at",
                table: "notifications",
                columns: new[] { "recipient_user_id", "is_read", "created_at" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "notifications");
        }
    }
}

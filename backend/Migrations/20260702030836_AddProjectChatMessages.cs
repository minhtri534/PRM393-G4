using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectChatMessages : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "project_chat_messages",
                columns: table => new
                {
                    message_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    project_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    sender_user_id = table.Column<string>(type: "varchar(24)", maxLength: 24, nullable: false),
                    message_type = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false),
                    content = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    attachment_object_key = table.Column<string>(type: "varchar(500)", maxLength: 500, nullable: true),
                    attachment_file_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    attachment_content_type = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: true),
                    attachment_size_bytes = table.Column<long>(type: "bigint", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "DATEADD(HOUR, 7, SYSUTCDATETIME())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_chat_messages", x => x.message_id);
                    table.ForeignKey(
                        name: "FK_project_chat_messages_Projects_project_id",
                        column: x => x.project_id,
                        principalTable: "Projects",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_project_chat_messages_Users_sender_user_id",
                        column: x => x.sender_user_id,
                        principalTable: "Users",
                        principalColumn: "_id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_project_chat_messages_project_id_created_at",
                table: "project_chat_messages",
                columns: new[] { "project_id", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_project_chat_messages_sender_user_id",
                table: "project_chat_messages",
                column: "sender_user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "project_chat_messages");
        }
    }
}

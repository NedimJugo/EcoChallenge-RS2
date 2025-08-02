using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class RequestParticipation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "RequestParticipationId",
                table: "Photos",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "RequestParticipations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    request_id = table.Column<int>(type: "int", nullable: false),
                    status = table.Column<int>(type: "int", nullable: false),
                    admin_notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    reward_points = table.Column<int>(type: "int", nullable: false),
                    reward_money = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: false),
                    submitted_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    approved_at = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RequestParticipations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RequestParticipations_Requests_request_id",
                        column: x => x.request_id,
                        principalTable: "Requests",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RequestParticipations_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 1,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 2,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 3,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 4,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 5,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 6,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 7,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 8,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 9,
                column: "RequestParticipationId",
                value: null);

            migrationBuilder.InsertData(
                table: "RequestParticipations",
                columns: new[] { "Id", "admin_notes", "approved_at", "request_id", "reward_money", "reward_points", "status", "submitted_at", "user_id" },
                values: new object[,]
                {
                    { 1, null, null, 3, 0.00m, 0, 0, new DateTime(2025, 8, 1, 14, 30, 0, 0, DateTimeKind.Utc), 1 },
                    { 2, "Good job! Cleaned thoroughly.", new DateTime(2025, 8, 2, 10, 0, 0, 0, DateTimeKind.Utc), 4, 10.00m, 50, 1, new DateTime(2025, 8, 1, 15, 0, 0, 0, DateTimeKind.Utc), 2 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Photos_RequestParticipationId",
                table: "Photos",
                column: "RequestParticipationId");

            migrationBuilder.CreateIndex(
                name: "IX_RequestParticipations_request_id",
                table: "RequestParticipations",
                column: "request_id");

            migrationBuilder.CreateIndex(
                name: "IX_RequestParticipations_user_id",
                table: "RequestParticipations",
                column: "user_id");

            migrationBuilder.AddForeignKey(
                name: "FK_Photos_RequestParticipations_RequestParticipationId",
                table: "Photos",
                column: "RequestParticipationId",
                principalTable: "RequestParticipations",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Photos_RequestParticipations_RequestParticipationId",
                table: "Photos");

            migrationBuilder.DropTable(
                name: "RequestParticipations");

            migrationBuilder.DropIndex(
                name: "IX_Photos_RequestParticipationId",
                table: "Photos");

            migrationBuilder.DropColumn(
                name: "RequestParticipationId",
                table: "Photos");
        }
    }
}

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class MoreDbChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ActivityHistories_Rewards_RewardId",
                table: "ActivityHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_Rewards_RewardId",
                table: "Notifications");

            migrationBuilder.DropTable(
                name: "Rewards");

            migrationBuilder.DropTable(
                name: "RewardTypes");

            migrationBuilder.DropIndex(
                name: "IX_Notifications_RewardId",
                table: "Notifications");

            migrationBuilder.DropIndex(
                name: "IX_ActivityHistories_RewardId",
                table: "ActivityHistories");

            migrationBuilder.DropColumn(
                name: "RewardId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "RewardId",
                table: "ActivityHistories");

            migrationBuilder.AddColumn<int>(
                name: "finance_manager_id",
                table: "RequestParticipations",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "finance_notes",
                table: "RequestParticipations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "finance_processed_at",
                table: "RequestParticipations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "finance_status",
                table: "RequestParticipations",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "RequestParticipations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "finance_manager_id", "finance_notes", "finance_processed_at", "finance_status" },
                values: new object[] { null, null, null, 0 });

            migrationBuilder.UpdateData(
                table: "RequestParticipations",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "finance_manager_id", "finance_notes", "finance_processed_at", "finance_status" },
                values: new object[] { null, null, null, 0 });

            migrationBuilder.CreateIndex(
                name: "IX_RequestParticipations_finance_manager_id",
                table: "RequestParticipations",
                column: "finance_manager_id");

            migrationBuilder.AddForeignKey(
                name: "FK_RequestParticipations_Users_finance_manager_id",
                table: "RequestParticipations",
                column: "finance_manager_id",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RequestParticipations_Users_finance_manager_id",
                table: "RequestParticipations");

            migrationBuilder.DropIndex(
                name: "IX_RequestParticipations_finance_manager_id",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "finance_manager_id",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "finance_notes",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "finance_processed_at",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "finance_status",
                table: "RequestParticipations");

            migrationBuilder.AddColumn<int>(
                name: "RewardId",
                table: "Notifications",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RewardId",
                table: "ActivityHistories",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "RewardTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RewardTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Rewards",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    approved_by_admin_id = table.Column<int>(type: "int", nullable: true),
                    badge_id = table.Column<int>(type: "int", nullable: true),
                    donation_id = table.Column<int>(type: "int", nullable: true),
                    event_id = table.Column<int>(type: "int", nullable: true),
                    request_id = table.Column<int>(type: "int", nullable: true),
                    reward_type_id = table.Column<int>(type: "int", nullable: false),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    approved_at = table.Column<DateTime>(type: "datetime2", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    currency = table.Column<string>(type: "nvarchar(3)", maxLength: 3, nullable: false),
                    money_amount = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: false),
                    paid_at = table.Column<DateTime>(type: "datetime2", nullable: true),
                    points_amount = table.Column<int>(type: "int", nullable: false),
                    reason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Rewards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Rewards_Badges_badge_id",
                        column: x => x.badge_id,
                        principalTable: "Badges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Rewards_Donations_donation_id",
                        column: x => x.donation_id,
                        principalTable: "Donations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Rewards_Events_event_id",
                        column: x => x.event_id,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Rewards_Requests_request_id",
                        column: x => x.request_id,
                        principalTable: "Requests",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Rewards_RewardTypes_reward_type_id",
                        column: x => x.reward_type_id,
                        principalTable: "RewardTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Rewards_Users_approved_by_admin_id",
                        column: x => x.approved_by_admin_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Rewards_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.UpdateData(
                table: "ActivityHistories",
                keyColumn: "Id",
                keyValue: 1,
                column: "RewardId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 1,
                column: "RewardId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 2,
                column: "RewardId",
                value: null);

            migrationBuilder.InsertData(
                table: "RewardTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Points" },
                    { 2, "Money" },
                    { 3, "Badge" },
                    { 4, "Combo" }
                });

            migrationBuilder.InsertData(
                table: "Rewards",
                columns: new[] { "Id", "approved_at", "approved_by_admin_id", "badge_id", "created_at", "currency", "donation_id", "event_id", "money_amount", "paid_at", "points_amount", "reason", "request_id", "reward_type_id", "status", "user_id" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, new DateTime(2025, 6, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", null, null, 0m, null, 50, null, 1, 1, 1, 2 },
                    { 2, null, null, 2, new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", 1, null, 0m, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, null, null, 3, 2, 2 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_RewardId",
                table: "Notifications",
                column: "RewardId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_RewardId",
                table: "ActivityHistories",
                column: "RewardId");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_approved_by_admin_id",
                table: "Rewards",
                column: "approved_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_badge_id",
                table: "Rewards",
                column: "badge_id");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_donation_id",
                table: "Rewards",
                column: "donation_id");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_event_id",
                table: "Rewards",
                column: "event_id");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_request_id",
                table: "Rewards",
                column: "request_id");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_reward_type_id",
                table: "Rewards",
                column: "reward_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_Rewards_user_id",
                table: "Rewards",
                column: "user_id");

            migrationBuilder.AddForeignKey(
                name: "FK_ActivityHistories_Rewards_RewardId",
                table: "ActivityHistories",
                column: "RewardId",
                principalTable: "Rewards",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_Rewards_RewardId",
                table: "Notifications",
                column: "RewardId",
                principalTable: "Rewards",
                principalColumn: "Id");
        }
    }
}

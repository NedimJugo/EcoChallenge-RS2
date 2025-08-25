using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class MoreDbChanges3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "Id", "admin_approved", "created_at", "creator_user_id", "current_participants", "description", "duration_minutes", "equipment_list", "equipment_provided", "event_date", "event_time", "event_type_id", "location_id", "max_participants", "meeting_point", "RequestId", "status_id", "title", "updated_at" },
                values: new object[,]
                {
                    { 3, false, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 0, null, 120, null, false, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 14, 0, 0, 0), 2, 2, 0, null, null, 1, "Beach Education", new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, false, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 0, null, 120, null, false, new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 14, 0, 0, 0), 2, 2, 0, null, null, 1, "Beach Education", new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 20.00m, 100 });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 21.00m, 100 });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 22.00m, 100 });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 23.00m, 100 });

            migrationBuilder.InsertData(
                table: "Photos",
                columns: new[] { "Id", "caption", "event_id", "image_url", "is_primary", "order_index", "photo_type", "request_id", "RequestParticipationId", "uploaded_at", "uploader_user_id" },
                values: new object[,]
                {
                    { 10, "Volunteers installing trail markers", 3, "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg", false, 3, 3, null, null, new DateTime(2025, 6, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), 6 },
                    { 11, "Volunteers installing trail markers", 4, "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg", false, 3, 3, null, null, new DateTime(2025, 6, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), 6 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Events",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Events",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 0m, 0 });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 0m, 0 });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 0m, 0 });

            migrationBuilder.UpdateData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "suggested_reward_money", "suggested_reward_points" },
                values: new object[] { 0m, 0 });
        }
    }
}

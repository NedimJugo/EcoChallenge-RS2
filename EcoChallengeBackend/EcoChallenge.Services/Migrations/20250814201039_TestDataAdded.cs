using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class TestDataAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "created_at", "criteria_type_id", "criteria_value", "description", "name" },
                values: new object[] { new DateTime(2025, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 1, null, "First Cleanup" });

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "created_at", "criteria_type_id", "criteria_value", "description", "name" },
                values: new object[] { new DateTime(2025, 4, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 1, null, "Donation Star" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "created_at", "criteria_type_id", "criteria_value", "description", "name" },
                values: new object[] { new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 100, "Earned your first 100 points", "First Steps" });

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "created_at", "criteria_type_id", "criteria_value", "description", "name" },
                values: new object[] { new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 500, "Accumulated 500 points", "Point Collector" });

            migrationBuilder.InsertData(
                table: "Badges",
                columns: new[] { "Id", "badge_type_id", "created_at", "criteria_type_id", "criteria_value", "description", "icon_url", "is_active", "name" },
                values: new object[] { 3, 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 1000, "Reached 1000 points", null, true, "Eco Warrior" });
        }
    }
}

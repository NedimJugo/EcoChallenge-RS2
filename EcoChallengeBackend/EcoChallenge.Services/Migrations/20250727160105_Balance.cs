using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class Balance : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BalanceSettings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WholeBalance = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    BalanceLeft = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedByAdminId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BalanceSettings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BalanceSettings_Users_UpdatedByAdminId",
                        column: x => x.UpdatedByAdminId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.InsertData(
                table: "BalanceSettings",
                columns: new[] { "Id", "BalanceLeft", "updated_at", "UpdatedByAdminId", "WholeBalance" },
                values: new object[] { 1, 1800.00m, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 20000.00m });

            migrationBuilder.CreateIndex(
                name: "IX_BalanceSettings_UpdatedByAdminId",
                table: "BalanceSettings",
                column: "UpdatedByAdminId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BalanceSettings");
        }
    }
}

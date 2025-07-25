using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class DbEntitesRemove : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_Requests_related_request_id",
                table: "Events");

            migrationBuilder.DropIndex(
                name: "IX_Events_related_request_id",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "is_paid_request",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "related_request_id",
                table: "Events");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "is_paid_request",
                table: "Events",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "related_request_id",
                table: "Events",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "is_paid_request", "related_request_id" },
                values: new object[] { false, 1 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "is_paid_request", "related_request_id" },
                values: new object[] { false, null });

            migrationBuilder.CreateIndex(
                name: "IX_Events_related_request_id",
                table: "Events",
                column: "related_request_id");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Requests_related_request_id",
                table: "Events",
                column: "related_request_id",
                principalTable: "Requests",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}

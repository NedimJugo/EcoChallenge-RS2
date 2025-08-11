using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentFieldsToRequestParticipation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "bank_name",
                table: "RequestParticipations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "card_holder_name",
                table: "RequestParticipations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "rejection_reason",
                table: "RequestParticipations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "transaction_number",
                table: "RequestParticipations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "RequestParticipations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "bank_name", "card_holder_name", "rejection_reason", "transaction_number" },
                values: new object[] { null, null, null, null });

            migrationBuilder.UpdateData(
                table: "RequestParticipations",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "bank_name", "card_holder_name", "rejection_reason", "transaction_number" },
                values: new object[] { null, null, null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "bank_name",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "card_holder_name",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "rejection_reason",
                table: "RequestParticipations");

            migrationBuilder.DropColumn(
                name: "transaction_number",
                table: "RequestParticipations");
        }
    }
}

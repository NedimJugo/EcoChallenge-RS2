using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class DonationChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "stripe_payment_intent_id",
                table: "Donations",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "stripe_payment_status",
                table: "Donations",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Donations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "stripe_payment_intent_id", "stripe_payment_status" },
                values: new object[] { null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "stripe_payment_intent_id",
                table: "Donations");

            migrationBuilder.DropColumn(
                name: "stripe_payment_status",
                table: "Donations");
        }
    }
}

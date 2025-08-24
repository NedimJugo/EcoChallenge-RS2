using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class MoreDbChanges2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/badge.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/eco.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 4,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 5,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/badge.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 6,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 7,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png");

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 8,
                column: "icon_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/badge.png");

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://ecochallengeblob.blob.core.windows.net/ecochallenge/16879a815fc12df11c9f29cb433ef446.jpg", "https://ecochallengeblob.blob.core.windows.net/ecochallenge/16879a815fc12df11c9f29cb433ef446.jpg" });

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg", "https://ecochallengeblob.blob.core.windows.net/ecochallenge/istockphoto-1448602820-170667a.jpg" });

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg", "https://ecochallengeblob.blob.core.windows.net/ecochallenge/istockphoto-1448602820-170667a.jpg" });

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg", "https://ecochallengeblob.blob.core.windows.net/ecochallenge/istockphoto-1448602820-170667a.jpg" });

            migrationBuilder.UpdateData(
                table: "Organizations",
                keyColumn: "Id",
                keyValue: 1,
                column: "logo_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/259-2593009_eco-logo-leaves-eco-friendly.png");

            migrationBuilder.UpdateData(
                table: "Organizations",
                keyColumn: "Id",
                keyValue: 2,
                column: "logo_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/259-2593009_eco-logo-leaves-eco-friendly.png");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 1,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 2,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 3,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 4,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 5,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 6,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 7,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 8,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 9,
                column: "image_url",
                value: "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "password_hash", "username" },
                values: new object[] { "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=", "desktop" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "password_hash", "username" },
                values: new object[] { "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=", "mobile" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "password_hash",
                value: "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "password_hash",
                value: "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "password_hash",
                value: "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "password_hash",
                value: "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 3,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 4,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 5,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 6,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 7,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 8,
                column: "icon_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://example.com/images/after/riverbank-park-1.jpg", "https://example.com/images/before/riverbank-park-1.jpg" });

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://example.com/images/after/city-beach-2.jpg", "https://example.com/images/before/city-beach-2.jpg" });

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://example.com/images/after/downtown-square-3.jpg", "https://example.com/images/before/downtown-square-3.jpg" });

            migrationBuilder.UpdateData(
                table: "GalleryShowcases",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "after_image_url", "before_image_url" },
                values: new object[] { "https://example.com/images/after/forest-trail-4.jpg", "https://example.com/images/before/forest-trail-4.jpg" });

            migrationBuilder.UpdateData(
                table: "Organizations",
                keyColumn: "Id",
                keyValue: 1,
                column: "logo_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Organizations",
                keyColumn: "Id",
                keyValue: 2,
                column: "logo_url",
                value: null);

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 1,
                column: "image_url",
                value: "https://example.com/photos/riverbank-before-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 2,
                column: "image_url",
                value: "https://example.com/photos/riverbank-after-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 3,
                column: "image_url",
                value: "https://example.com/photos/beach-before-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 4,
                column: "image_url",
                value: "https://example.com/photos/beach-after-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 5,
                column: "image_url",
                value: "https://example.com/photos/downtown-before-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 6,
                column: "image_url",
                value: "https://example.com/photos/downtown-after-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 7,
                column: "image_url",
                value: "https://example.com/photos/forest-before-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 8,
                column: "image_url",
                value: "https://example.com/photos/forest-after-1.jpg");

            migrationBuilder.UpdateData(
                table: "Photos",
                keyColumn: "Id",
                keyValue: 9,
                column: "image_url",
                value: "https://example.com/photos/forest-progress-1.jpg");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "password_hash", "username" },
                values: new object[] { "HASH1", "alice" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "password_hash", "username" },
                values: new object[] { "HASH2", "bob" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "password_hash",
                value: "HASH3");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "password_hash",
                value: "HASH4");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "password_hash",
                value: "HASH5");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "password_hash",
                value: "HASH6");
        }
    }
}

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddingTestData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "SettingId",
                table: "SystemSettings",
                newName: "Id");

            migrationBuilder.InsertData(
                table: "Badges",
                columns: new[] { "Id", "badge_type", "created_at", "criteria_type", "criteria_value", "description", "icon_url", "is_active", "name" },
                values: new object[,]
                {
                    { 1, 2, new DateTime(2025, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, 1, null, null, true, "First Cleanup" },
                    { 2, 1, new DateTime(2025, 4, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 1, null, null, true, "Donation Star" }
                });

            migrationBuilder.InsertData(
                table: "Locations",
                columns: new[] { "Id", "address", "city", "country", "created_at", "description", "latitude", "location_type", "longitude", "name", "postal_code" },
                values: new object[,]
                {
                    { 1, null, "Mostar", "BiH", new DateTime(2025, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 43.3436m, 4, 17.8083m, "Riverbank Park", null },
                    { 2, null, "Neum", "BiH", new DateTime(2025, 3, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 42.4300m, 2, 18.6413m, "City Beach", null }
                });

            migrationBuilder.InsertData(
                table: "Organizations",
                columns: new[] { "Id", "category", "contact_email", "contact_phone", "created_at", "description", "is_active", "is_verified", "logo_url", "name", "updated_at", "website" },
                values: new object[,]
                {
                    { 1, null, "contact@greenearth.org", null, new DateTime(2025, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Environmental NGO", true, false, null, "GreenEarth", new DateTime(2025, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "https://greenearth.org" },
                    { 2, null, "info@oceancare.org", null, new DateTime(2025, 2, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), "Marine conservation group", true, false, null, "OceanCare", new DateTime(2025, 2, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), "https://oceancare.org" }
                });

            migrationBuilder.InsertData(
                table: "SystemSettings",
                columns: new[] { "Id", "created_at", "description", "is_public", "setting_key", "setting_type", "updated_at", "updated_by_admin_id", "setting_value" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, true, "default_points_per_cleanup", 1, new DateTime(2025, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "50" },
                    { 2, new DateTime(2025, 5, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, false, "maintenance_mode", 3, new DateTime(2025, 5, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "false" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "city", "country", "created_at", "date_of_birth", "deactivated_at", "email", "first_name", "is_active", "last_login", "last_name", "password_hash", "phone_number", "profile_image_url", "total_cleanups", "total_events_organized", "total_events_participated", "total_points", "updated_at", "user_type", "username" },
                values: new object[,]
                {
                    { 1, "Mostar", "BiH", new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "alice@example.com", "Alice", true, null, "Anderson", "HASH1", null, null, 0, 0, 0, 0, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "alice" },
                    { 2, "Sarajevo", "BiH", new DateTime(2025, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "bob@example.com", "Bob", true, null, "Baker", "HASH2", null, null, 0, 0, 0, 0, new DateTime(2025, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, "bob" },
                    { 3, "Mostar", "BiH", new DateTime(2025, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "carol@example.com", "Carol", true, null, "Clark", "HASH3", null, null, 0, 0, 0, 0, new DateTime(2025, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "carol" }
                });

            migrationBuilder.InsertData(
                table: "ActivityHistories",
                columns: new[] { "Id", "activity_type", "created_at", "description", "DonationId", "EventId", "money_earned", "points_earned", "related_entity_id", "related_entity_type", "RequestId", "RewardId", "user_id" },
                values: new object[] { 1, 0, new DateTime(2025, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, null, null, 0, 1, 0, null, null, 2 });

            migrationBuilder.InsertData(
                table: "AdminLogs",
                columns: new[] { "Id", "action_description", "action_type", "admin_user_id", "created_at", "ip_address", "new_values", "old_values", "target_entity_id", "target_entity_type", "user_agent" },
                values: new object[] { 1, "Approved request #2", 0, 1, new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, null, 2, 1, null });

            migrationBuilder.InsertData(
                table: "Donations",
                columns: new[] { "Id", "amount", "created_at", "currency", "donation_message", "is_anonymous", "organization_id", "payment_method", "payment_reference", "points_earned", "processed_at", "status", "user_id" },
                values: new object[] { 1, 20.00m, new DateTime(2025, 6, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", null, false, 1, null, null, 0, new DateTime(2025, 6, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 2 });

            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "Id", "admin_approved", "created_at", "creator_user_id", "current_participants", "description", "duration_minutes", "equipment_list", "equipment_provided", "event_date", "event_time", "event_type", "image_url", "is_paid_request", "location_id", "max_participants", "meeting_point", "related_request_id", "RequestId", "status", "title", "updated_at" },
                values: new object[] { 2, false, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 0, null, 120, null, false, new DateTime(2025, 7, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 14, 0, 0, 0), 1, null, false, 2, 0, null, null, null, 0, "Beach Education", new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "created_at", "is_pushed", "is_read", "message", "notification_type", "read_at", "related_entity_id", "related_entity_type", "RewardId", "title", "user_id" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, "We’ve approved your request #1. Thank you!", 0, null, null, null, null, "Your cleanup request was approved", 2 },
                    { 2, new DateTime(2025, 6, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, "Don’t forget our Park Cleanup event on 2025-07-01 at 09:00.", 2, null, null, null, null, "Reminder: Park Cleanup tomorrow", 2 }
                });

            migrationBuilder.InsertData(
                table: "Reports",
                columns: new[] { "Id", "admin_notes", "created_at", "report_description", "reported_entity_id", "reported_entity_type", "report_reason", "reporter_user_id", "resolved_at", "resolved_by_admin_id", "status" },
                values: new object[] { 1, null, new DateTime(2025, 6, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 2, 0, 0, 3, null, null, 0 });

            migrationBuilder.InsertData(
                table: "Requests",
                columns: new[] { "Id", "actual_reward_money", "actual_reward_points", "admin_notes", "ai_analysis_result", "approved_at", "assigned_admin_id", "completed_at", "completion_image_url", "completion_notes", "created_at", "description", "estimated_amount", "estimated_cleanup_time", "image_url", "location_id", "proposed_date", "proposed_time", "rejection_reason", "status", "suggested_reward_money", "suggested_reward_points", "title", "updated_at", "urgency_level", "user_id", "waste_type" },
                values: new object[,]
                {
                    { 1, 0m, 0, null, null, null, null, null, null, null, new DateTime(2025, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 0, null, null, 1, null, null, null, 0, 0m, 0, "Trash at Park", new DateTime(2025, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 2, 4 },
                    { 2, 0m, 0, null, null, null, 1, null, null, null, new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 2, null, null, 2, null, null, null, 1, 0m, 0, "Plastic on Beach", new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 3, 0 }
                });

            migrationBuilder.InsertData(
                table: "UserBadges",
                columns: new[] { "Id", "badge_id", "earned_at", "user_id" },
                values: new object[] { 1, 1, new DateTime(2025, 6, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 });

            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "Id", "admin_approved", "created_at", "creator_user_id", "current_participants", "description", "duration_minutes", "equipment_list", "equipment_provided", "event_date", "event_time", "event_type", "image_url", "is_paid_request", "location_id", "max_participants", "meeting_point", "related_request_id", "RequestId", "status", "title", "updated_at" },
                values: new object[] { 1, false, new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 0, null, 120, null, false, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 9, 0, 0, 0), 0, null, false, 1, 0, null, 1, null, 1, "Park Cleanup", new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Galleries",
                columns: new[] { "Id", "caption", "dislikes_count", "event_id", "image_type", "image_url", "is_approved", "is_featured", "is_reported", "likes_count", "location_id", "report_count", "request_id", "uploaded_at", "uploader_user_id" },
                values: new object[] { 1, null, 0, null, 0, "/images/before1.jpg", true, false, false, 0, 1, 0, 1, new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 });

            migrationBuilder.InsertData(
                table: "Rewards",
                columns: new[] { "Id", "approved_at", "approved_by_admin_id", "badge_id", "created_at", "currency", "donation_id", "event_id", "money_amount", "paid_at", "points_amount", "reason", "request_id", "reward_type", "status", "user_id" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, new DateTime(2025, 6, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", null, null, 0m, null, 50, null, 1, 0, 1, 2 },
                    { 2, null, null, 2, new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", 1, null, 0m, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, null, null, 2, 2, 2 }
                });

            migrationBuilder.InsertData(
                table: "ChatMessages",
                columns: new[] { "Id", "event_id", "image_url", "is_admin_message", "is_deleted", "is_reported", "message_text", "message_type", "report_reason", "reported_by_user_id", "sender_user_id", "sent_at" },
                values: new object[] { 1, 1, null, false, false, false, "Looking forward to helping!", 0, null, null, 2, new DateTime(2025, 6, 20, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "EventParticipants",
                columns: new[] { "Id", "event_id", "joined_at", "points_earned", "attendance_status", "user_id" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 6, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, 0, 2 },
                    { 2, 1, new DateTime(2025, 6, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, 0, 3 }
                });

            migrationBuilder.InsertData(
                table: "Galleries",
                columns: new[] { "Id", "caption", "dislikes_count", "event_id", "image_type", "image_url", "is_approved", "is_featured", "is_reported", "likes_count", "location_id", "report_count", "request_id", "uploaded_at", "uploader_user_id" },
                values: new object[] { 2, null, 0, 1, 2, "/images/during1.jpg", true, false, false, 0, 1, 0, null, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 3 });

            migrationBuilder.InsertData(
                table: "GalleryReactions",
                columns: new[] { "Id", "created_at", "gallery_id", "GalleryId1", "reaction_type", "user_id" },
                values: new object[] { 1, new DateTime(2025, 6, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, null, 0, 3 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "ActivityHistories",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "AdminLogs",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ChatMessages",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "EventParticipants",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "EventParticipants",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Events",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Galleries",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "GalleryReactions",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Organizations",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Reports",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Rewards",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Rewards",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "SystemSettings",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "SystemSettings",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "UserBadges",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Badges",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Donations",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Events",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Galleries",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Organizations",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "SystemSettings",
                newName: "SettingId");
        }
    }
}

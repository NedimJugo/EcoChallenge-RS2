using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace EcoChallenge.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BadgeTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BadgeTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CriteriaType",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CriteriaType", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DonationStatuses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DonationStatuses", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "EntityTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EntityTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "EventStatuses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventStatuses", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "EventTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Locations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    latitude = table.Column<decimal>(type: "decimal(10,8)", precision: 10, scale: 8, nullable: false),
                    longitude = table.Column<decimal>(type: "decimal(11,8)", precision: 11, scale: 8, nullable: false),
                    address = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    city = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    country = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    postal_code = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    location_type = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Locations", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Organizations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    website = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    logo_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    contact_email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    contact_phone = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    category = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    is_verified = table.Column<bool>(type: "bit", nullable: false),
                    is_active = table.Column<bool>(type: "bit", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Organizations", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RequestStatuses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RequestStatuses", x => x.Id);
                });

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
                name: "TargetEntityTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TargetEntityTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "WasteTypes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WasteTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Badges",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    icon_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    badge_type_id = table.Column<int>(type: "int", nullable: false),
                    criteria_type_id = table.Column<int>(type: "int", nullable: false),
                    criteria_value = table.Column<int>(type: "int", nullable: false),
                    is_active = table.Column<bool>(type: "bit", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Badges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Badges_BadgeTypes_badge_type_id",
                        column: x => x.badge_type_id,
                        principalTable: "BadgeTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Badges_CriteriaType_criteria_type_id",
                        column: x => x.criteria_type_id,
                        principalTable: "CriteriaType",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    username = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    password_hash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    first_name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    last_name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    profile_image_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    phone_number = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    date_of_birth = table.Column<DateTime>(type: "datetime2", nullable: true),
                    city = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    country = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    total_points = table.Column<int>(type: "int", nullable: false),
                    total_cleanups = table.Column<int>(type: "int", nullable: false),
                    total_events_organized = table.Column<int>(type: "int", nullable: false),
                    total_events_participated = table.Column<int>(type: "int", nullable: false),
                    user_type_id = table.Column<int>(type: "int", nullable: false),
                    is_active = table.Column<bool>(type: "bit", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    last_login = table.Column<DateTime>(type: "datetime2", nullable: true),
                    deactivated_at = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Users_UserTypes_user_type_id",
                        column: x => x.user_type_id,
                        principalTable: "UserTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AdminLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    admin_user_id = table.Column<int>(type: "int", nullable: false),
                    action_type = table.Column<int>(type: "int", nullable: false),
                    target_entity_type_id = table.Column<int>(type: "int", nullable: false),
                    action_description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    old_values = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    new_values = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ip_address = table.Column<string>(type: "nvarchar(45)", maxLength: 45, nullable: true),
                    user_agent = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AdminLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AdminLogs_TargetEntityTypes_target_entity_type_id",
                        column: x => x.target_entity_type_id,
                        principalTable: "TargetEntityTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AdminLogs_Users_admin_user_id",
                        column: x => x.admin_user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Donations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    organization_id = table.Column<int>(type: "int", nullable: false),
                    amount = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: false),
                    currency = table.Column<string>(type: "nvarchar(3)", maxLength: 3, nullable: false),
                    payment_method = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    payment_reference = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    donation_message = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    is_anonymous = table.Column<bool>(type: "bit", nullable: false),
                    status_id = table.Column<int>(type: "int", nullable: false),
                    points_earned = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    processed_at = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Donations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Donations_DonationStatuses_status_id",
                        column: x => x.status_id,
                        principalTable: "DonationStatuses",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Donations_Organizations_organization_id",
                        column: x => x.organization_id,
                        principalTable: "Organizations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Donations_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Reports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    reporter_user_id = table.Column<int>(type: "int", nullable: false),
                    reported_entity_type_id = table.Column<int>(type: "int", nullable: false),
                    report_reason = table.Column<int>(type: "int", nullable: false),
                    report_description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    status = table.Column<int>(type: "int", nullable: false),
                    admin_notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    resolved_by_admin_id = table.Column<int>(type: "int", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    resolved_at = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reports_TargetEntityTypes_reported_entity_type_id",
                        column: x => x.reported_entity_type_id,
                        principalTable: "TargetEntityTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reports_Users_reporter_user_id",
                        column: x => x.reporter_user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reports_Users_resolved_by_admin_id",
                        column: x => x.resolved_by_admin_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Requests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    location_id = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    image_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    estimated_cleanup_time = table.Column<int>(type: "int", nullable: true),
                    urgency_level = table.Column<int>(type: "int", nullable: false),
                    waste_type_id = table.Column<int>(type: "int", nullable: false),
                    estimated_amount = table.Column<int>(type: "int", nullable: false),
                    proposed_date = table.Column<DateTime>(type: "datetime2", nullable: true),
                    proposed_time = table.Column<TimeSpan>(type: "time", nullable: true),
                    status_id = table.Column<int>(type: "int", nullable: false),
                    admin_notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    rejection_reason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    suggested_reward_points = table.Column<int>(type: "int", nullable: false),
                    suggested_reward_money = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: false),
                    actual_reward_points = table.Column<int>(type: "int", nullable: false),
                    actual_reward_money = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: false),
                    ai_analysis_result = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    completion_image_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    completion_notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    assigned_admin_id = table.Column<int>(type: "int", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    approved_at = table.Column<DateTime>(type: "datetime2", nullable: true),
                    completed_at = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Requests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Requests_Locations_location_id",
                        column: x => x.location_id,
                        principalTable: "Locations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Requests_RequestStatuses_status_id",
                        column: x => x.status_id,
                        principalTable: "RequestStatuses",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Requests_Users_assigned_admin_id",
                        column: x => x.assigned_admin_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Requests_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Requests_WasteTypes_waste_type_id",
                        column: x => x.waste_type_id,
                        principalTable: "WasteTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SystemSettings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    setting_key = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    setting_value = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    setting_type = table.Column<int>(type: "int", nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    is_public = table.Column<bool>(type: "bit", nullable: false),
                    updated_by_admin_id = table.Column<int>(type: "int", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SystemSettings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SystemSettings_Users_updated_by_admin_id",
                        column: x => x.updated_by_admin_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "UserBadges",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    badge_id = table.Column<int>(type: "int", nullable: false),
                    earned_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserBadges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserBadges_Badges_badge_id",
                        column: x => x.badge_id,
                        principalTable: "Badges",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserBadges_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    creator_user_id = table.Column<int>(type: "int", nullable: false),
                    location_id = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    image_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    event_type_id = table.Column<int>(type: "int", nullable: false),
                    max_participants = table.Column<int>(type: "int", nullable: false),
                    current_participants = table.Column<int>(type: "int", nullable: false),
                    event_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    event_time = table.Column<TimeSpan>(type: "time", nullable: false),
                    duration_minutes = table.Column<int>(type: "int", nullable: false),
                    equipment_provided = table.Column<bool>(type: "bit", nullable: false),
                    equipment_list = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    meeting_point = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    status_id = table.Column<int>(type: "int", nullable: false),
                    is_paid_request = table.Column<bool>(type: "bit", nullable: false),
                    related_request_id = table.Column<int>(type: "int", nullable: true),
                    admin_approved = table.Column<bool>(type: "bit", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RequestId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Events_EventStatuses_status_id",
                        column: x => x.status_id,
                        principalTable: "EventStatuses",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Events_EventTypes_event_type_id",
                        column: x => x.event_type_id,
                        principalTable: "EventTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Events_Locations_location_id",
                        column: x => x.location_id,
                        principalTable: "Locations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Events_Requests_RequestId",
                        column: x => x.RequestId,
                        principalTable: "Requests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Events_Requests_related_request_id",
                        column: x => x.related_request_id,
                        principalTable: "Requests",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Events_Users_creator_user_id",
                        column: x => x.creator_user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ChatMessages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    event_id = table.Column<int>(type: "int", nullable: false),
                    sender_user_id = table.Column<int>(type: "int", nullable: false),
                    message_text = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    message_type = table.Column<int>(type: "int", nullable: false),
                    image_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    is_admin_message = table.Column<bool>(type: "bit", nullable: false),
                    is_reported = table.Column<bool>(type: "bit", nullable: false),
                    reported_by_user_id = table.Column<int>(type: "int", nullable: true),
                    report_reason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    is_deleted = table.Column<bool>(type: "bit", nullable: false),
                    sent_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatMessages_Events_event_id",
                        column: x => x.event_id,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ChatMessages_Users_reported_by_user_id",
                        column: x => x.reported_by_user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_ChatMessages_Users_sender_user_id",
                        column: x => x.sender_user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "EventParticipants",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    event_id = table.Column<int>(type: "int", nullable: false),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    joined_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    attendance_status = table.Column<int>(type: "int", nullable: false),
                    points_earned = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventParticipants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EventParticipants_Events_event_id",
                        column: x => x.event_id,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EventParticipants_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Galleries",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    request_id = table.Column<int>(type: "int", nullable: true),
                    event_id = table.Column<int>(type: "int", nullable: true),
                    location_id = table.Column<int>(type: "int", nullable: false),
                    uploader_user_id = table.Column<int>(type: "int", nullable: false),
                    image_url = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    image_type = table.Column<int>(type: "int", nullable: false),
                    caption = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    likes_count = table.Column<int>(type: "int", nullable: false),
                    dislikes_count = table.Column<int>(type: "int", nullable: false),
                    is_featured = table.Column<bool>(type: "bit", nullable: false),
                    is_approved = table.Column<bool>(type: "bit", nullable: false),
                    is_reported = table.Column<bool>(type: "bit", nullable: false),
                    report_count = table.Column<int>(type: "int", nullable: false),
                    uploaded_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Galleries", x => x.Id);
                    table.CheckConstraint("CK_Gallery_RelatedEntity", "request_id IS NOT NULL OR event_id IS NOT NULL");
                    table.ForeignKey(
                        name: "FK_Galleries_Events_event_id",
                        column: x => x.event_id,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Galleries_Locations_location_id",
                        column: x => x.location_id,
                        principalTable: "Locations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Galleries_Requests_request_id",
                        column: x => x.request_id,
                        principalTable: "Requests",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Galleries_Users_uploader_user_id",
                        column: x => x.uploader_user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Rewards",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    request_id = table.Column<int>(type: "int", nullable: true),
                    event_id = table.Column<int>(type: "int", nullable: true),
                    donation_id = table.Column<int>(type: "int", nullable: true),
                    reward_type_id = table.Column<int>(type: "int", nullable: false),
                    points_amount = table.Column<int>(type: "int", nullable: false),
                    money_amount = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: false),
                    currency = table.Column<string>(type: "nvarchar(3)", maxLength: 3, nullable: false),
                    badge_id = table.Column<int>(type: "int", nullable: true),
                    reason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    status = table.Column<int>(type: "int", nullable: false),
                    approved_by_admin_id = table.Column<int>(type: "int", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    approved_at = table.Column<DateTime>(type: "datetime2", nullable: true),
                    paid_at = table.Column<DateTime>(type: "datetime2", nullable: true)
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

            migrationBuilder.CreateTable(
                name: "GalleryReactions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    gallery_id = table.Column<int>(type: "int", nullable: false),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    reaction_type = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    GalleryId1 = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GalleryReactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GalleryReactions_Galleries_GalleryId1",
                        column: x => x.GalleryId1,
                        principalTable: "Galleries",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_GalleryReactions_Galleries_gallery_id",
                        column: x => x.gallery_id,
                        principalTable: "Galleries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_GalleryReactions_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ActivityHistories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    activity_type = table.Column<int>(type: "int", nullable: false),
                    related_entity_type_id = table.Column<int>(type: "int", nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    points_earned = table.Column<int>(type: "int", nullable: true),
                    money_earned = table.Column<decimal>(type: "decimal(10,2)", precision: 10, scale: 2, nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DonationId = table.Column<int>(type: "int", nullable: true),
                    EventId = table.Column<int>(type: "int", nullable: true),
                    RequestId = table.Column<int>(type: "int", nullable: true),
                    RewardId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ActivityHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ActivityHistories_Donations_DonationId",
                        column: x => x.DonationId,
                        principalTable: "Donations",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ActivityHistories_EntityTypes_related_entity_type_id",
                        column: x => x.related_entity_type_id,
                        principalTable: "EntityTypes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ActivityHistories_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ActivityHistories_Requests_RequestId",
                        column: x => x.RequestId,
                        principalTable: "Requests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ActivityHistories_Rewards_RewardId",
                        column: x => x.RewardId,
                        principalTable: "Rewards",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ActivityHistories_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    notification_type = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    message = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    is_read = table.Column<bool>(type: "bit", nullable: false),
                    is_pushed = table.Column<bool>(type: "bit", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    read_at = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RewardId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notifications_Rewards_RewardId",
                        column: x => x.RewardId,
                        principalTable: "Rewards",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Notifications_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "BadgeTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Participation" },
                    { 2, "Achievement" },
                    { 3, "Milestone" },
                    { 4, "Special" }
                });

            migrationBuilder.InsertData(
                table: "CriteriaType",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Count" },
                    { 2, "Points" },
                    { 3, "EventsOrganized" },
                    { 4, "DonationsMade" },
                    { 5, "Special" }
                });

            migrationBuilder.InsertData(
                table: "DonationStatuses",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Pending" },
                    { 2, "Completed" },
                    { 3, "Failed" }
                });

            migrationBuilder.InsertData(
                table: "EntityTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Request" },
                    { 2, "Event" },
                    { 3, "Donation" },
                    { 4, "Badge" },
                    { 5, "Reward" },
                    { 6, "Message" },
                    { 7, "Gallery" },
                    { 8, "User " }
                });

            migrationBuilder.InsertData(
                table: "EventStatuses",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Draft" },
                    { 2, "Published" },
                    { 3, "Completed" },
                    { 4, "InProgress" },
                    { 5, "Cancelled" }
                });

            migrationBuilder.InsertData(
                table: "EventTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Cleanup" },
                    { 2, "Community " },
                    { 3, "Fundraiser" }
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
                table: "RequestStatuses",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Pending" },
                    { 2, "UnderReview" },
                    { 3, "Approved" },
                    { 4, "Rejected" },
                    { 5, "InProgress" },
                    { 6, "Completed" },
                    { 7, "Cancelled " }
                });

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
                table: "SystemSettings",
                columns: new[] { "Id", "created_at", "description", "is_public", "setting_key", "setting_type", "updated_at", "updated_by_admin_id", "setting_value" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, true, "default_points_per_cleanup", 1, new DateTime(2025, 5, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "50" },
                    { 2, new DateTime(2025, 5, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, false, "maintenance_mode", 3, new DateTime(2025, 5, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, "false" }
                });

            migrationBuilder.InsertData(
                table: "TargetEntityTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "User" },
                    { 2, "Request" },
                    { 3, "Event" },
                    { 4, "Reward" },
                    { 5, "Organization" },
                    { 6, "System " }
                });

            migrationBuilder.InsertData(
                table: "UserTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Admin" },
                    { 2, "User" },
                    { 3, "Moderator" },
                    { 4, "Finance" }
                });

            migrationBuilder.InsertData(
                table: "WasteTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Plastic" },
                    { 2, "Glass" },
                    { 3, "Metal" },
                    { 4, "Organic" },
                    { 5, "Mixed" },
                    { 6, "Hazardous" },
                    { 7, "Other " }
                });

            migrationBuilder.InsertData(
                table: "Badges",
                columns: new[] { "Id", "badge_type_id", "created_at", "criteria_type_id", "criteria_value", "description", "icon_url", "is_active", "name" },
                values: new object[,]
                {
                    { 1, 3, new DateTime(2025, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 1, null, null, true, "First Cleanup" },
                    { 2, 2, new DateTime(2025, 4, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 1, null, null, true, "Donation Star" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "city", "country", "created_at", "date_of_birth", "deactivated_at", "email", "first_name", "is_active", "last_login", "last_name", "password_hash", "phone_number", "profile_image_url", "total_cleanups", "total_events_organized", "total_events_participated", "total_points", "updated_at", "user_type_id", "username" },
                values: new object[,]
                {
                    { 1, "Mostar", "BiH", new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "alice@example.com", "Alice", true, null, "Anderson", "HASH1", null, null, 0, 0, 0, 0, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "alice" },
                    { 2, "Sarajevo", "BiH", new DateTime(2025, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "bob@example.com", "Bob", true, null, "Baker", "HASH2", null, null, 0, 0, 0, 0, new DateTime(2025, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "bob" },
                    { 3, "Mostar", "BiH", new DateTime(2025, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, "carol@example.com", "Carol", true, null, "Clark", "HASH3", null, null, 0, 0, 0, 0, new DateTime(2025, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, "carol" }
                });

            migrationBuilder.InsertData(
                table: "ActivityHistories",
                columns: new[] { "Id", "activity_type", "created_at", "description", "DonationId", "EventId", "money_earned", "points_earned", "related_entity_type_id", "RequestId", "RewardId", "user_id" },
                values: new object[] { 1, 0, new DateTime(2025, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, null, null, 0, 1, null, null, 2 });

            migrationBuilder.InsertData(
                table: "AdminLogs",
                columns: new[] { "Id", "action_description", "action_type", "admin_user_id", "created_at", "ip_address", "new_values", "old_values", "target_entity_type_id", "user_agent" },
                values: new object[] { 1, "Approved request #2", 0, 1, new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, null, 2, null });

            migrationBuilder.InsertData(
                table: "Donations",
                columns: new[] { "Id", "amount", "created_at", "currency", "donation_message", "is_anonymous", "organization_id", "payment_method", "payment_reference", "points_earned", "processed_at", "status_id", "user_id" },
                values: new object[] { 1, 20.00m, new DateTime(2025, 6, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", null, false, 1, null, null, 0, new DateTime(2025, 6, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 2 });

            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "Id", "admin_approved", "created_at", "creator_user_id", "current_participants", "description", "duration_minutes", "equipment_list", "equipment_provided", "event_date", "event_time", "event_type_id", "image_url", "is_paid_request", "location_id", "max_participants", "meeting_point", "related_request_id", "RequestId", "status_id", "title", "updated_at" },
                values: new object[] { 2, false, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 0, null, 120, null, false, new DateTime(2025, 7, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 14, 0, 0, 0), 2, null, false, 2, 0, null, null, null, 1, "Beach Education", new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "created_at", "is_pushed", "is_read", "message", "notification_type", "read_at", "RewardId", "title", "user_id" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, "We’ve approved your request #1. Thank you!", 0, null, null, "Your cleanup request was approved", 2 },
                    { 2, new DateTime(2025, 6, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, "Don’t forget our Park Cleanup event on 2025-07-01 at 09:00.", 2, null, null, "Reminder: Park Cleanup tomorrow", 2 }
                });

            migrationBuilder.InsertData(
                table: "Reports",
                columns: new[] { "Id", "admin_notes", "created_at", "report_description", "reported_entity_type_id", "report_reason", "reporter_user_id", "resolved_at", "resolved_by_admin_id", "status" },
                values: new object[] { 1, null, new DateTime(2025, 6, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 2, 0, 3, null, null, 0 });

            migrationBuilder.InsertData(
                table: "Requests",
                columns: new[] { "Id", "actual_reward_money", "actual_reward_points", "admin_notes", "ai_analysis_result", "approved_at", "assigned_admin_id", "completed_at", "completion_image_url", "completion_notes", "created_at", "description", "estimated_amount", "estimated_cleanup_time", "image_url", "location_id", "proposed_date", "proposed_time", "rejection_reason", "status_id", "suggested_reward_money", "suggested_reward_points", "title", "updated_at", "urgency_level", "user_id", "waste_type_id" },
                values: new object[,]
                {
                    { 1, 0m, 0, null, null, null, null, null, null, null, new DateTime(2025, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 0, null, null, 1, null, null, null, 1, 0m, 0, "Trash at Park", new DateTime(2025, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 2, 5 },
                    { 2, 0m, 0, null, null, null, 1, null, null, null, new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null, 2, null, null, 2, null, null, null, 2, 0m, 0, "Plastic on Beach", new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 3, 1 }
                });

            migrationBuilder.InsertData(
                table: "UserBadges",
                columns: new[] { "Id", "badge_id", "earned_at", "user_id" },
                values: new object[] { 1, 1, new DateTime(2025, 6, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 });

            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "Id", "admin_approved", "created_at", "creator_user_id", "current_participants", "description", "duration_minutes", "equipment_list", "equipment_provided", "event_date", "event_time", "event_type_id", "image_url", "is_paid_request", "location_id", "max_participants", "meeting_point", "related_request_id", "RequestId", "status_id", "title", "updated_at" },
                values: new object[] { 1, false, new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 0, null, 120, null, false, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 9, 0, 0, 0), 1, null, false, 1, 0, null, 1, null, 2, "Park Cleanup", new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Galleries",
                columns: new[] { "Id", "caption", "dislikes_count", "event_id", "image_type", "image_url", "is_approved", "is_featured", "is_reported", "likes_count", "location_id", "report_count", "request_id", "uploaded_at", "uploader_user_id" },
                values: new object[] { 1, null, 0, null, 0, "/images/before1.jpg", true, false, false, 0, 1, 0, 1, new DateTime(2025, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 });

            migrationBuilder.InsertData(
                table: "Rewards",
                columns: new[] { "Id", "approved_at", "approved_by_admin_id", "badge_id", "created_at", "currency", "donation_id", "event_id", "money_amount", "paid_at", "points_amount", "reason", "request_id", "reward_type_id", "status", "user_id" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, new DateTime(2025, 6, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", null, null, 0m, null, 50, null, 1, 1, 1, 2 },
                    { 2, null, null, 2, new DateTime(2025, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "USD", 1, null, 0m, new DateTime(2025, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 0, null, null, 3, 2, 2 }
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

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_created_at",
                table: "ActivityHistories",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_DonationId",
                table: "ActivityHistories",
                column: "DonationId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_EventId",
                table: "ActivityHistories",
                column: "EventId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_related_entity_type_id",
                table: "ActivityHistories",
                column: "related_entity_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_RequestId",
                table: "ActivityHistories",
                column: "RequestId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_RewardId",
                table: "ActivityHistories",
                column: "RewardId");

            migrationBuilder.CreateIndex(
                name: "IX_ActivityHistories_user_id",
                table: "ActivityHistories",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_AdminLogs_admin_user_id",
                table: "AdminLogs",
                column: "admin_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_AdminLogs_target_entity_type_id",
                table: "AdminLogs",
                column: "target_entity_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_Badges_badge_type_id",
                table: "Badges",
                column: "badge_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_Badges_criteria_type_id",
                table: "Badges",
                column: "criteria_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_event_id",
                table: "ChatMessages",
                column: "event_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_reported_by_user_id",
                table: "ChatMessages",
                column: "reported_by_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_sender_user_id",
                table: "ChatMessages",
                column: "sender_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Donations_organization_id",
                table: "Donations",
                column: "organization_id");

            migrationBuilder.CreateIndex(
                name: "IX_Donations_status_id",
                table: "Donations",
                column: "status_id");

            migrationBuilder.CreateIndex(
                name: "IX_Donations_user_id",
                table: "Donations",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_EventParticipants_event_id_user_id",
                table: "EventParticipants",
                columns: new[] { "event_id", "user_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EventParticipants_user_id",
                table: "EventParticipants",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Events_creator_user_id",
                table: "Events",
                column: "creator_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Events_event_date",
                table: "Events",
                column: "event_date");

            migrationBuilder.CreateIndex(
                name: "IX_Events_event_type_id",
                table: "Events",
                column: "event_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_Events_location_id",
                table: "Events",
                column: "location_id");

            migrationBuilder.CreateIndex(
                name: "IX_Events_related_request_id",
                table: "Events",
                column: "related_request_id");

            migrationBuilder.CreateIndex(
                name: "IX_Events_RequestId",
                table: "Events",
                column: "RequestId");

            migrationBuilder.CreateIndex(
                name: "IX_Events_status_id",
                table: "Events",
                column: "status_id");

            migrationBuilder.CreateIndex(
                name: "IX_Galleries_event_id",
                table: "Galleries",
                column: "event_id");

            migrationBuilder.CreateIndex(
                name: "IX_Galleries_is_featured",
                table: "Galleries",
                column: "is_featured");

            migrationBuilder.CreateIndex(
                name: "IX_Galleries_location_id",
                table: "Galleries",
                column: "location_id");

            migrationBuilder.CreateIndex(
                name: "IX_Galleries_request_id",
                table: "Galleries",
                column: "request_id");

            migrationBuilder.CreateIndex(
                name: "IX_Galleries_uploaded_at",
                table: "Galleries",
                column: "uploaded_at");

            migrationBuilder.CreateIndex(
                name: "IX_Galleries_uploader_user_id",
                table: "Galleries",
                column: "uploader_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_GalleryReactions_gallery_id_user_id",
                table: "GalleryReactions",
                columns: new[] { "gallery_id", "user_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GalleryReactions_GalleryId1",
                table: "GalleryReactions",
                column: "GalleryId1");

            migrationBuilder.CreateIndex(
                name: "IX_GalleryReactions_user_id",
                table: "GalleryReactions",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Locations_latitude_longitude",
                table: "Locations",
                columns: new[] { "latitude", "longitude" });

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_RewardId",
                table: "Notifications",
                column: "RewardId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_user_id",
                table: "Notifications",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Reports_reported_entity_type_id",
                table: "Reports",
                column: "reported_entity_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_Reports_reporter_user_id",
                table: "Reports",
                column: "reporter_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Reports_resolved_by_admin_id",
                table: "Reports",
                column: "resolved_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_Requests_assigned_admin_id",
                table: "Requests",
                column: "assigned_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_Requests_created_at",
                table: "Requests",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "IX_Requests_location_id",
                table: "Requests",
                column: "location_id");

            migrationBuilder.CreateIndex(
                name: "IX_Requests_status_id",
                table: "Requests",
                column: "status_id");

            migrationBuilder.CreateIndex(
                name: "IX_Requests_user_id",
                table: "Requests",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Requests_waste_type_id",
                table: "Requests",
                column: "waste_type_id");

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

            migrationBuilder.CreateIndex(
                name: "IX_SystemSettings_setting_key",
                table: "SystemSettings",
                column: "setting_key",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SystemSettings_updated_by_admin_id",
                table: "SystemSettings",
                column: "updated_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_UserBadges_badge_id",
                table: "UserBadges",
                column: "badge_id");

            migrationBuilder.CreateIndex(
                name: "IX_UserBadges_user_id_badge_id",
                table: "UserBadges",
                columns: new[] { "user_id", "badge_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_email",
                table: "Users",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_user_type_id",
                table: "Users",
                column: "user_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_Users_username",
                table: "Users",
                column: "username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ActivityHistories");

            migrationBuilder.DropTable(
                name: "AdminLogs");

            migrationBuilder.DropTable(
                name: "ChatMessages");

            migrationBuilder.DropTable(
                name: "EventParticipants");

            migrationBuilder.DropTable(
                name: "GalleryReactions");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "Reports");

            migrationBuilder.DropTable(
                name: "SystemSettings");

            migrationBuilder.DropTable(
                name: "UserBadges");

            migrationBuilder.DropTable(
                name: "EntityTypes");

            migrationBuilder.DropTable(
                name: "Galleries");

            migrationBuilder.DropTable(
                name: "Rewards");

            migrationBuilder.DropTable(
                name: "TargetEntityTypes");

            migrationBuilder.DropTable(
                name: "Badges");

            migrationBuilder.DropTable(
                name: "Donations");

            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.DropTable(
                name: "RewardTypes");

            migrationBuilder.DropTable(
                name: "BadgeTypes");

            migrationBuilder.DropTable(
                name: "CriteriaType");

            migrationBuilder.DropTable(
                name: "DonationStatuses");

            migrationBuilder.DropTable(
                name: "Organizations");

            migrationBuilder.DropTable(
                name: "EventStatuses");

            migrationBuilder.DropTable(
                name: "EventTypes");

            migrationBuilder.DropTable(
                name: "Requests");

            migrationBuilder.DropTable(
                name: "Locations");

            migrationBuilder.DropTable(
                name: "RequestStatuses");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "WasteTypes");

            migrationBuilder.DropTable(
                name: "UserTypes");
        }
    }
}

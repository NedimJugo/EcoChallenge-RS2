using EcoChallenge.Services.Database.Entities;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Database
{
    public class EcoChallengeDbContext : DbContext
    {
        public EcoChallengeDbContext(DbContextOptions<EcoChallengeDbContext> options)
            : base(options)
        {
        }

        // DbSets
        public DbSet<User> Users { get; set; }
        public DbSet<Organization> Organizations { get; set; }
        public DbSet<Location> Locations { get; set; }
        public DbSet<RequestStatus> RequestStatuses { get; set; }
        public DbSet<Request> Requests { get; set; }
        public DbSet<EventStatus> EventStatuses { get; set; }
        public DbSet<Event> Events { get; set; }
        public DbSet<EventParticipant> EventParticipants { get; set; }
        public DbSet<ChatMessage> ChatMessages { get; set; }
        public DbSet<DonationStatus> DonationStatuses { get; set; }
        public DbSet<Donation> Donations { get; set; }
        public DbSet<Reward> Rewards { get; set; }
        public DbSet<Badge> Badges { get; set; }
        public DbSet<UserBadge> UserBadges { get; set; }
        public DbSet<Gallery> Galleries { get; set; }
        public DbSet<GalleryReaction> GalleryReactions { get; set; }
        public DbSet<ActivityHistory> ActivityHistories { get; set; }
        public DbSet<AdminLog> AdminLogs { get; set; }
        public DbSet<SystemSetting> SystemSettings { get; set; }
        public DbSet<Report> Reports { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<BadgeType> BadgeTypes { get; set; }
        public DbSet<EventType> EventTypes { get; set; }
        public DbSet<RewardType> RewardTypes { get; set; }
        public DbSet<TargetEntityType> TargetEntityTypes { get; set; }
        public DbSet<UserType> UserTypes { get; set; }
        public DbSet<WasteType> WasteTypes { get; set; }
        public DbSet<EntityType> EntityTypes { get; set; }



        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User relationships
            ConfigureUserRelationships(modelBuilder);

            // Configure Request relationships
            ConfigureRequestRelationships(modelBuilder);

            // Configure Event relationships
            ConfigureEventRelationships(modelBuilder);

            // Configure Chat relationships
            ConfigureChatRelationships(modelBuilder);

            // Configure Donation relationships
            ConfigureDonationRelationships(modelBuilder);

            // Configure Reward relationships
            ConfigureRewardRelationships(modelBuilder);

            // Configure Badge relationships
            ConfigureBadgeRelationships(modelBuilder);

            // Configure Gallery relationships
            ConfigureGalleryRelationships(modelBuilder);

            // Configure Activity and Admin relationships
            ConfigureActivityAndAdminRelationships(modelBuilder);

            // Configure Report relationships
            ConfigureReportRelationships(modelBuilder);

            // Configure Notification relationships
            ConfigureNotificationRelationships(modelBuilder);

            // Configure indexes
            ConfigureIndexes(modelBuilder);

            // Configure constraints
            ConfigureConstraints(modelBuilder);
        }

        private void ConfigureUserRelationships(ModelBuilder modelBuilder)
        {
            // User self-referencing relationships are handled through separate entities
            // No direct self-reference in User entity
        }

        private void ConfigureRequestRelationships(ModelBuilder modelBuilder)
        {
            // Request -> User (Creator)
            modelBuilder.Entity<Request>()
                .HasOne(r => r.User)
                .WithMany(u => u.Requests)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Request -> User (Assigned Admin)
            modelBuilder.Entity<Request>()
                .HasOne(r => r.AssignedAdmin)
                .WithMany(u => u.AssignedRequests)
                .HasForeignKey(r => r.AssignedAdminId)
                .OnDelete(DeleteBehavior.SetNull);

            // Request -> Location
            modelBuilder.Entity<Request>()
                .HasOne(r => r.Location)
                .WithMany(l => l.Requests)
                .HasForeignKey(r => r.LocationId)
                .OnDelete(DeleteBehavior.Restrict);
        }

        private void ConfigureEventRelationships(ModelBuilder modelBuilder)
        {
            // Event -> User (Creator)
            modelBuilder.Entity<Event>()
                .HasOne(e => e.Creator)
                .WithMany(u => u.CreatedEvents)
                .HasForeignKey(e => e.CreatorUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Event -> Location
            modelBuilder.Entity<Event>()
                .HasOne(e => e.Location)
                .WithMany(l => l.Events)
                .HasForeignKey(e => e.LocationId)
                .OnDelete(DeleteBehavior.Restrict);

            // Event -> Request (Related)
            modelBuilder.Entity<Event>()
                .HasOne(e => e.RelatedRequest)
                .WithMany()
                .HasForeignKey(e => e.RelatedRequestId)
                .OnDelete(DeleteBehavior.SetNull);

            // EventParticipant relationships
            modelBuilder.Entity<EventParticipant>()
                .HasOne(ep => ep.Event)
                .WithMany(e => e.Participants)
                .HasForeignKey(ep => ep.EventId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<EventParticipant>()
                .HasOne(ep => ep.User)
                .WithMany(u => u.EventParticipants)
                .HasForeignKey(ep => ep.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Unique constraint for EventParticipant
            modelBuilder.Entity<EventParticipant>()
                .HasIndex(ep => new { ep.EventId, ep.UserId })
                .IsUnique();
        }

        private void ConfigureChatRelationships(ModelBuilder modelBuilder)
        {
            // ChatMessage -> Event
            modelBuilder.Entity<ChatMessage>()
                .HasOne(cm => cm.Event)
                .WithMany(e => e.ChatMessages)
                .HasForeignKey(cm => cm.EventId)
                .OnDelete(DeleteBehavior.Cascade);

            // ChatMessage -> User (Sender)
            modelBuilder.Entity<ChatMessage>()
                .HasOne(cm => cm.Sender)
                .WithMany(u => u.ChatMessages)
                .HasForeignKey(cm => cm.SenderUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // ChatMessage -> User (Reported By)
            modelBuilder.Entity<ChatMessage>()
                .HasOne(cm => cm.ReportedBy)
                .WithMany()
                .HasForeignKey(cm => cm.ReportedByUserId)
                .OnDelete(DeleteBehavior.SetNull);
        }

        private void ConfigureDonationRelationships(ModelBuilder modelBuilder)
        {
            // Donation -> User
            modelBuilder.Entity<Donation>()
                .HasOne(d => d.User)
                .WithMany(u => u.Donations)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Donation -> Organization
            modelBuilder.Entity<Donation>()
                .HasOne(d => d.Organization)
                .WithMany(o => o.Donations)
                .HasForeignKey(d => d.OrganizationId)
                .OnDelete(DeleteBehavior.Restrict);
        }

        private void ConfigureRewardRelationships(ModelBuilder modelBuilder)
        {
            // Reward -> User
            modelBuilder.Entity<Reward>()
                .HasOne(r => r.User)
                .WithMany(u => u.Rewards)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Reward -> Request
            modelBuilder.Entity<Reward>()
                .HasOne(r => r.Request)
                .WithMany(req => req.Rewards)
                .HasForeignKey(r => r.RequestId)
                .OnDelete(DeleteBehavior.SetNull);

            // Reward -> Event
            modelBuilder.Entity<Reward>()
                .HasOne(r => r.Event)
                .WithMany(e => e.Rewards)
                .HasForeignKey(r => r.EventId)
                .OnDelete(DeleteBehavior.SetNull);

            // Reward -> Donation
            modelBuilder.Entity<Reward>()
                .HasOne(r => r.Donation)
                .WithMany(d => d.Rewards)
                .HasForeignKey(r => r.DonationId)
                .OnDelete(DeleteBehavior.SetNull);

            // Reward -> Badge
            modelBuilder.Entity<Reward>()
                .HasOne(r => r.Badge)
                .WithMany(b => b.Rewards)
                .HasForeignKey(r => r.BadgeId)
                .OnDelete(DeleteBehavior.SetNull);

            // Reward -> User (Approved By)
            modelBuilder.Entity<Reward>()
                .HasOne(r => r.ApprovedBy)
                .WithMany()
                .HasForeignKey(r => r.ApprovedByAdminId)
                .OnDelete(DeleteBehavior.SetNull);
        }

        private void ConfigureBadgeRelationships(ModelBuilder modelBuilder)
        {
            // UserBadge relationships
            modelBuilder.Entity<UserBadge>()
                .HasOne(ub => ub.User)
                .WithMany(u => u.UserBadges)
                .HasForeignKey(ub => ub.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserBadge>()
                .HasOne(ub => ub.Badge)
                .WithMany(b => b.UserBadges)
                .HasForeignKey(ub => ub.BadgeId)
                .OnDelete(DeleteBehavior.Restrict);

            // Unique constraint for UserBadge
            modelBuilder.Entity<UserBadge>()
                .HasIndex(ub => new { ub.UserId, ub.BadgeId })
                .IsUnique();
        }

        private void ConfigureGalleryRelationships(ModelBuilder modelBuilder)
        {
            // Gallery -> Request
            modelBuilder.Entity<Gallery>()
                .HasOne(g => g.Request)
                .WithMany(r => r.Galleries)
                .HasForeignKey(g => g.RequestId)
                .OnDelete(DeleteBehavior.SetNull);

            // Gallery -> Event
            modelBuilder.Entity<Gallery>()
                .HasOne(g => g.Event)
                .WithMany(e => e.Galleries)
                .HasForeignKey(g => g.EventId)
                .OnDelete(DeleteBehavior.SetNull);

            // Gallery -> Location
            modelBuilder.Entity<Gallery>()
                .HasOne(g => g.Location)
                .WithMany(l => l.Galleries)
                .HasForeignKey(g => g.LocationId)
                .OnDelete(DeleteBehavior.Restrict);

            // Gallery -> User (Uploader)
            modelBuilder.Entity<Gallery>()
                .HasOne(g => g.User)
                .WithMany(u => u.Galleries)
                .HasForeignKey(g => g.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // GalleryReaction relationships
            modelBuilder.Entity<GalleryReaction>()
                .HasOne(gr => gr.Gallery)
                .WithMany()
                .HasForeignKey(gr => gr.GalleryId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GalleryReaction>()
                .HasOne(gr => gr.User)
                .WithMany(u => u.GalleryReactions)
                .HasForeignKey(gr => gr.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Unique constraint for GalleryReaction
            modelBuilder.Entity<GalleryReaction>()
                .HasIndex(gr => new { gr.GalleryId, gr.UserId })
                .IsUnique();
        }

        private void ConfigureActivityAndAdminRelationships(ModelBuilder modelBuilder)
        {
            // ActivityHistory -> User
            modelBuilder.Entity<ActivityHistory>()
                .HasOne(ah => ah.User)
                .WithMany(u => u.ActivityHistories)
                .HasForeignKey(ah => ah.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // AdminLog -> User
            modelBuilder.Entity<AdminLog>()
                .HasOne(al => al.AdminUser)
                .WithMany(u => u.AdminLogs)
                .HasForeignKey(al => al.AdminUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // SystemSetting -> User (Updated By)
            modelBuilder.Entity<SystemSetting>()
                .HasOne(ss => ss.UpdatedBy)
                .WithMany(u => u.UpdatedSettings)
                .HasForeignKey(ss => ss.UpdatedByAdminId)
                .OnDelete(DeleteBehavior.SetNull);
        }

        private void ConfigureReportRelationships(ModelBuilder modelBuilder)
        {
            // Report -> User (Reporter)
            modelBuilder.Entity<Report>()
                .HasOne(r => r.Reporter)
                .WithMany(u => u.Reports)
                .HasForeignKey(r => r.ReporterUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Report -> User (Resolved By)
            modelBuilder.Entity<Report>()
                .HasOne(r => r.ResolvedBy)
                .WithMany(u => u.ResolvedReports)
                .HasForeignKey(r => r.ResolvedByAdminId)
                .OnDelete(DeleteBehavior.SetNull);
        }

        private void ConfigureNotificationRelationships(ModelBuilder modelBuilder)
        {
            // Notification -> User
            modelBuilder.Entity<Notification>()
                .HasOne(n => n.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        }

        private void ConfigureIndexes(ModelBuilder modelBuilder)
        {
            // User indexes
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            // Request indexes
            modelBuilder.Entity<Request>()
                .HasIndex(r => r.StatusId);

            modelBuilder.Entity<Request>()
                .HasIndex(r => r.CreatedAt);

            modelBuilder.Entity<Request>()
                .HasIndex(r => r.UserId);

            // Event indexes
            modelBuilder.Entity<Event>()
                .HasIndex(e => e.EventDate);

            modelBuilder.Entity<Event>()
                .HasIndex(e => e.StatusId);

            modelBuilder.Entity<Event>()
                .HasIndex(e => e.CreatorUserId);

            // Location indexes
            modelBuilder.Entity<Location>()
                .HasIndex(l => new { l.Latitude, l.Longitude });

            // Gallery indexes
            modelBuilder.Entity<Gallery>()
                .HasIndex(g => g.UploadedAt);

            modelBuilder.Entity<Gallery>()
                .HasIndex(g => g.IsFeatured);

            // ActivityHistory indexes
            modelBuilder.Entity<ActivityHistory>()
                .HasIndex(ah => ah.CreatedAt);

            modelBuilder.Entity<ActivityHistory>()
                .HasIndex(ah => ah.UserId);

            // SystemSetting indexes
            modelBuilder.Entity<SystemSetting>()
                .HasIndex(ss => ss.Key)
                .IsUnique();



            modelBuilder.SeedTestData();
        }

        private void ConfigureConstraints(ModelBuilder modelBuilder)
        {
            // Check constraints can be added here if needed
            // For example, ensuring positive values for amounts, etc.

            // Gallery constraint - must be related to either Request or Event
            modelBuilder.Entity<Gallery>()
                .ToTable(t => t.HasCheckConstraint("CK_Gallery_RelatedEntity",
                    "request_id IS NOT NULL OR event_id IS NOT NULL"));
        }

        // Override SaveChanges to handle UpdatedAt timestamps
        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return base.SaveChangesAsync(cancellationToken);
        }

        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Modified)
                .Where(e => e.Entity.GetType().GetProperty("UpdatedAt") != null);

            foreach (var entry in entries)
            {
                entry.Property("UpdatedAt").CurrentValue = DateTime.UtcNow;
            }
        }
    }
}

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
        public DbSet<DonationStatus> DonationStatuses { get; set; }
        public DbSet<Donation> Donations { get; set; }
        public DbSet<Reward> Rewards { get; set; }
        public DbSet<Badge> Badges { get; set; }
        public DbSet<UserBadge> UserBadges { get; set; }
        public DbSet<GalleryReaction> GalleryReactions { get; set; }
        public DbSet<ActivityHistory> ActivityHistories { get; set; }
        public DbSet<AdminLog> AdminLogs { get; set; }
        public DbSet<SystemSetting> SystemSettings { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<BadgeType> BadgeTypes { get; set; }
        public DbSet<EventType> EventTypes { get; set; }
        public DbSet<RewardType> RewardTypes { get; set; }
        public DbSet<TargetEntityType> TargetEntityTypes { get; set; }
        public DbSet<UserType> UserTypes { get; set; }
        public DbSet<WasteType> WasteTypes { get; set; }
        public DbSet<EntityType> EntityTypes { get; set; }
        public DbSet<GalleryShowcase> GalleryShowcases { get; set; }
        public DbSet<Photo> Photos { get; set; }

        public DbSet<BalanceSetting> BalanceSettings { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User relationships
            ConfigureUserRelationships(modelBuilder);

            // Configure Request relationships
            ConfigureRequestRelationships(modelBuilder);

            // Configure Event relationships
            ConfigureEventRelationships(modelBuilder);

            // Configure Donation relationships
            ConfigureDonationRelationships(modelBuilder);

            // Configure Reward relationships
            ConfigureRewardRelationships(modelBuilder);

            // Configure Badge relationships
            ConfigureBadgeRelationships(modelBuilder);

            // Configure Gallery relationships
            ConfigureMediaRelationships(modelBuilder);

            // Configure Activity and Admin relationships
            ConfigureActivityAndAdminRelationships(modelBuilder);

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

        private void ConfigureMediaRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<GalleryShowcase>()
                .HasOne(gs => gs.Request)
                .WithMany(r => r.GalleryShowcases)
                .HasForeignKey(gs => gs.RequestId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<GalleryShowcase>()
                .HasOne(gs => gs.Event)
                .WithMany(e => e.GalleryShowcases)
                .HasForeignKey(gs => gs.EventId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<GalleryShowcase>()
                .HasOne(gs => gs.Location)
                .WithMany(l => l.GalleryShowcases)
                .HasForeignKey(gs => gs.LocationId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<GalleryShowcase>()
                .HasOne(gs => gs.CreatedByAdmin)
                .WithMany(u => u.CreatedGalleryShowcases)
                .HasForeignKey(gs => gs.CreatedByAdminId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<GalleryReaction>()
                .HasOne(gr => gr.GalleryShowcase)
                .WithMany(gs => gs.Reactions)
                .HasForeignKey(gr => gr.GalleryShowcaseId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GalleryReaction>()
                .HasOne(gr => gr.User)
                .WithMany(u => u.GalleryReactions)
                .HasForeignKey(gr => gr.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Photo>()
                .HasOne(p => p.Event)
                .WithMany(e => e.Photos)
                .HasForeignKey(p => p.EventId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<Photo>()
                .HasOne(p => p.Request)
                .WithMany(r => r.Photos)
                .HasForeignKey(p => p.RequestId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<Photo>()
                .HasOne(p => p.User)
                .WithMany(u => u.Photos)
                .HasForeignKey(p => p.UserId)
                .OnDelete(DeleteBehavior.Restrict);


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
            modelBuilder.Entity<GalleryReaction>()
                .HasIndex(gr => new { gr.GalleryShowcaseId, gr.UserId })
                .IsUnique();

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
            modelBuilder.Entity<GalleryShowcase>()
                .ToTable(t => t.HasCheckConstraint("CK_GalleryShowcase_RelatedEntity",
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

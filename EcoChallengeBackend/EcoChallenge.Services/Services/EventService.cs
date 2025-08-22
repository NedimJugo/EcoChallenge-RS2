using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Services.Interfeces;
using AutoMapper.QueryableExtensions;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Models.Enums;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace EcoChallenge.Services.Services
{
    public class EventService : BaseCRUDService<EventResponse, EventSearchObject, Event, EventInsertRequest, EventUpdateRequest>, IEventService

    {
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<EventService> _logger;

        public EventService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService, IServiceProvider serviceProvider, ILogger<EventService> logger) : base(db, mapper)
        {
            _db = db;
            _blobService = blobService;
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override IQueryable<Event> ApplyFilter(IQueryable<Event> query, EventSearchObject s)
        {

            query = query
               .Include(e => e.Creator)
               .Include(e => e.Location)
               .Include(e => e.EventType)
               .Include(e => e.Status)
               .Include(r => r.Photos);
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                string t = s.Text.ToLower();
                query.Where(e =>
                    e.Title!.ToLower().Contains(t) ||
                    e.Description!.ToLower().Contains(t) ||
                    e.EquipmentList!.ToLower().Contains(t) ||
                    e.MeetingPoint!.ToLower().Contains(t));
            }

            if (s.Status.HasValue)
                query = query.Where(e => e.StatusId == s.Status.Value);

            if (s.Type.HasValue)
                query = query.Where(e => e.EventTypeId == s.Type.Value);

            if (s.CreatorUserId.HasValue)
                query = query.Where(e => e.CreatorUserId == s.CreatorUserId.Value);

            if (s.LocationId.HasValue)
                query = query.Where(e => e.LocationId == s.LocationId.Value);

            return query;
        }
        public override async Task<EventResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Events
                .Include(e => e.Creator)
                .Include(e => e.Location)
                .Include(e => e.EventType)
                .Include(e => e.Status)
                .Include(r => r.Photos)
                .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }




        protected override async Task BeforeInsert(Event entity, EventInsertRequest request, CancellationToken cancellationToken = default)
        {
            if (request.Photos != null && request.Photos.Any())
            {
                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.CreatorUserId,
                        PhotoType = PhotoType.General,
                        IsPrimary = entity.Photos.Count == 0,
                        EventId = entity.Id
                    });
                }
            }

            await base.BeforeInsert(entity, request, cancellationToken);

            _ = Task.Run(async () =>
            {
                try
                {
                    using var scope = _serviceProvider.CreateScope();
                    var badgeService = scope.ServiceProvider.GetRequiredService<IBadgeManagementService>();
                    await badgeService.CheckEventsBadgesAsync(entity.CreatorUserId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to check badges for user {UserId} after event creation", entity.CreatorUserId);
                }
            });
        }

        protected override async Task BeforeUpdate(Event entity, EventUpdateRequest request, CancellationToken cancellationToken = default)
        {
            if (request.Photos != null && request.Photos.Any())
            {
                var existingPhotos = await _context.Photos
                    .Where(p => p.EventId == entity.Id)
                    .ToListAsync(cancellationToken);

                _context.Photos.RemoveRange(existingPhotos);

                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.CreatorUserId,
                        PhotoType = PhotoType.General,
                        IsPrimary = entity.Photos.Count == 0,
                        EventId = entity.Id
                    });
                }
            }

            await base.BeforeUpdate(entity, request, cancellationToken);
        }
    }
}

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

namespace EcoChallenge.Services.Services
{
    public class EventService : BaseCRUDService<EventResponse, EventSearchObject, Event, EventInsertRequest, EventUpdateRequest>, IEventService

    {
        private readonly EcoChallengeDbContext _db;

        public EventService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;

        }

        protected override IQueryable<Event> ApplyFilter(IQueryable<Event> query, EventSearchObject s)
        {

            query = query
               .Include(e => e.Creator)
               .Include(e => e.Location)
               .Include(e => e.EventType)
               .Include(e => e.Status)
               .Include(e => e.RelatedRequest)
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
                .Include(e => e.RelatedRequest)
                .Include(r => r.Photos)
                .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }
    }
}

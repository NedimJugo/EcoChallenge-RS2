using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Services
{
    public class EventTypeService : BaseCRUDService<EventTypeResponse, EventTypeSearchObject, EventType, EventTypeInsertRequest, EventTypeUpdateRequest>, IEventTypeService
    {
        private readonly EcoChallengeDbContext _db;

        public EventTypeService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<EventType> ApplyFilter(IQueryable<EventType> query, EventTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            return query;
        }

        public override async Task<EventTypeResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.EventTypes
                .Include(e => e.Events)
                .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }

        protected override async Task BeforeDelete(EventType entity, CancellationToken cancellationToken = default)
        {
            var hasEventType = await _db.Events.AnyAsync(u => u.EventTypeId == entity.Id, cancellationToken);


            if (hasEventType)
            {
                throw new InvalidOperationException($"Cannot delete event type '{entity.Name}' because it is being used by one or more events.");
            }

            await base.BeforeDelete(entity, cancellationToken);
        }
    }
}

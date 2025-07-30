using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class EventParticipantService : BaseCRUDService<EventParticipantResponse, EventParticipantSearchObject, EventParticipant, EventParticipantInsertRequest, EventParticipantUpdateRequest>, IEventParticipantService
    {
        public EventParticipantService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
        }

        protected override IQueryable<EventParticipant> ApplyFilter(IQueryable<EventParticipant> query, EventParticipantSearchObject s)
        {
            if (s.EventId.HasValue)
                query = query.Where(ep => ep.EventId == s.EventId.Value);

            if (s.UserId.HasValue)
                query = query.Where(ep => ep.UserId == s.UserId.Value);

            return query
                .Include(ep => ep.Event)
                .Include(ep => ep.User);
        }

        public override async Task<EventParticipantResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.EventParticipants
                .Include(ep => ep.Event)
                .Include(ep => ep.User)
                .FirstOrDefaultAsync(ep => ep.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }
    }
}

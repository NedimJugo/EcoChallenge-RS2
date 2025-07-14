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
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                string t = s.Text.ToLower();
                query = query.Where(e =>
                    e.Title!.ToLower().Contains(t) ||
                    e.Description!.ToLower().Contains(t) ||
                    e.EquipmentList!.ToLower().Contains(t) ||
                    e.MeetingPoint!.ToLower().Contains(t));
            }

            if (s.Status.HasValue)
                query = query.Where(e => e.Status == s.Status);

            if (s.Type.HasValue)
                query = query.Where(e => e.EventType == s.Type);

            if (s.CreatorUserId.HasValue)
                query = query.Where(e => e.CreatorUserId == s.CreatorUserId);

            if (s.LocationId.HasValue)
                query = query.Where(e => e.LocationId == s.LocationId);

            return query;
        }
    }
}

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
    public class EventService: BaseCRUDService<EventResponse, EventSearchObject, Event, EventInsertRequest, EventUpdateRequest>, IEventService

    {
        private readonly EcoChallengeDbContext _db;

        public EventService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;

        }
    }
}

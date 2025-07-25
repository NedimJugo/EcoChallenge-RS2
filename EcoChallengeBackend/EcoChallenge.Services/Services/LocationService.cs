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

namespace EcoChallenge.Services.Services
{
    public class LocationService : BaseCRUDService<LocationResponse, LocationSearchObject, Location, LocationInsertRequest, LocationUpdateRequest>, ILocationService
    {
        private readonly EcoChallengeDbContext _db;

        public LocationService(EcoChallengeDbContext db, IMapper mapper)
            : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<Location> ApplyFilter(IQueryable<Location> query, LocationSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search.City))
            {
                query = query.Where(x => x.City.ToLower().Contains(search.City.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search.Country))
            {
                query = query.Where(x => x.Country.ToLower().Contains(search.Country.ToLower()));
            }

            if (search.LocationType.HasValue)
            {
                query = query.Where(x => x.LocationType == search.LocationType.Value);
            }

            return query;
        }
    }
}

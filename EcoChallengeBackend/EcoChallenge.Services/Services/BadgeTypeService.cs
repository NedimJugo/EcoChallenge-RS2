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
    public class BadgeTypeService : BaseCRUDService<BadgeTypeResponse, BadgeTypeSearchObject, BadgeType, BadgeTypeInsertRequest, BadgeTypeUpdateRequest>, IBadgeTypeService
    {
        public BadgeTypeService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
        }

        protected override IQueryable<BadgeType> ApplyFilter(IQueryable<BadgeType> query, BadgeTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            return query;
        }
    }
}

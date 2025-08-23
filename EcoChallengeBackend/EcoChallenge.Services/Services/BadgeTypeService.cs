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
    public class BadgeTypeService : BaseCRUDService<BadgeTypeResponse, BadgeTypeSearchObject, BadgeType, BadgeTypeInsertRequest, BadgeTypeUpdateRequest>, IBadgeTypeService
    {
        private readonly EcoChallengeDbContext _db;

        public BadgeTypeService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<BadgeType> ApplyFilter(IQueryable<BadgeType> query, BadgeTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            return query;
        }

        protected override async Task BeforeDelete(BadgeType entity, CancellationToken cancellationToken = default)
        {
            var hasBadgeType = await _db.Badges.AnyAsync(u => u.BadgeTypeId == entity.Id, cancellationToken);


            if (hasBadgeType)
            {
                throw new InvalidOperationException($"Cannot delete badge type '{entity.Name}' because it is being used by one or more badges.");
            }

            await base.BeforeDelete(entity, cancellationToken);
        }
    }
}

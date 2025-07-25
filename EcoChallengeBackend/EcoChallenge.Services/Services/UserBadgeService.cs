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
    public class UserBadgeService : BaseCRUDService<UserBadgeResponse, UserBadgeSearchObject, UserBadge, UserBadgeInsertRequest, UserBadgeUpdateRequest>, IUserBadgeService
    {
        private readonly EcoChallengeDbContext _db;

        public UserBadgeService(EcoChallengeDbContext db, IMapper mapper)
            : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<UserBadge> ApplyFilter(IQueryable<UserBadge> query, UserBadgeSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.BadgeId.HasValue)
                query = query.Where(x => x.BadgeId == search.BadgeId.Value);

            if (search.FromDate.HasValue)
                query = query.Where(x => x.EarnedAt >= search.FromDate.Value);

            if (search.ToDate.HasValue)
                query = query.Where(x => x.EarnedAt <= search.ToDate.Value);

            return query;
        }
    }
}

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
    public class RewardService : BaseCRUDService<RewardResponse, RewardSearchObject, Reward, RewardInsertRequest, RewardUpdateRequest>, IRewardService
    {
        private readonly EcoChallengeDbContext _db;

        public RewardService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<Reward> ApplyFilter(IQueryable<Reward> query, RewardSearchObject s)
        {
            query = query.Include(r => r.User)
                         .Include(r => r.ApprovedBy)
                         .Include(r => r.RewardType)
                         .Include(r => r.Badge);

            if (s.UserId.HasValue)
                query = query.Where(r => r.UserId == s.UserId.Value);

            if (s.RewardTypeId.HasValue)
                query = query.Where(r => r.RewardTypeId == s.RewardTypeId.Value);

            if (s.Status.HasValue)
                query = query.Where(r => r.Status == s.Status.Value);

            if (s.ApprovedByAdminId.HasValue)
                query = query.Where(r => r.ApprovedByAdminId == s.ApprovedByAdminId.Value);

            if (s.DonationId.HasValue)
                query = query.Where(r => r.DonationId == s.DonationId.Value);

            if (s.EventId.HasValue)
                query = query.Where(r => r.EventId == s.EventId.Value);

            return query;
        }
    }
}

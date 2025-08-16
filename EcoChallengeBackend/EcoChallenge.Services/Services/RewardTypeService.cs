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
    public class RewardTypeService : BaseCRUDService<RewardTypeResponse, RewardTypeSearchObject, RewardType, RewardTypeInsertRequest, RewardTypeUpdateRequest>, IRewardTypeService
    {
        public RewardTypeService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
        }

        protected override IQueryable<RewardType> ApplyFilter(IQueryable<RewardType> query, RewardTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            return query;
        }

        public override async Task<RewardTypeResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.RewardTypes
                .Include(r => r.Rewards)
                .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }
    }

}

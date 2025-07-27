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
    public class BalanceSettingService : BaseCRUDService<BalanceSettingResponse, BalanceSettingSearchObject, BalanceSetting, BalanceSettingInsertRequest, BalanceSettingUpdateRequest>, IBalanceSettingService
    {
        public BalanceSettingService(EcoChallengeDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override async Task BeforeInsert(BalanceSetting entity, BalanceSettingInsertRequest request, CancellationToken cancellationToken = default)
        {
            entity.UpdatedAt = DateTime.UtcNow;
            await base.BeforeInsert(entity, request, cancellationToken);
        }

        protected override async Task BeforeUpdate(BalanceSetting entity, BalanceSettingUpdateRequest request, CancellationToken cancellationToken = default)
        {
            entity.UpdatedAt = DateTime.UtcNow;
            await base.BeforeUpdate(entity, request, cancellationToken);
        }

    }


}

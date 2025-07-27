using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Mapping
{
    public class BalanceSettingProfile : Profile
    {
        public BalanceSettingProfile()
        {
            CreateMap<BalanceSetting, BalanceSettingResponse>()
                .ForMember(dest => dest.UpdatedByName,
                           opt => opt.MapFrom(src => src.UpdatedBy != null ? src.UpdatedBy.Username : null));

            CreateMap<BalanceSettingInsertRequest, BalanceSetting>();
            CreateMap<BalanceSettingUpdateRequest, BalanceSetting>();
        }
    }

}

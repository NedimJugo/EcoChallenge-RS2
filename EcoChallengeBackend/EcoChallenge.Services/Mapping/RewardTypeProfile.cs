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
    public class RewardTypeProfile : Profile
    {
        public RewardTypeProfile()
        {
            CreateMap<RewardType, RewardTypeResponse>();
            CreateMap<RewardTypeInsertRequest, RewardType>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.Rewards, o => o.Ignore());
            CreateMap<RewardTypeUpdateRequest, RewardType>()
                .ForMember(e => e.Rewards, o => o.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

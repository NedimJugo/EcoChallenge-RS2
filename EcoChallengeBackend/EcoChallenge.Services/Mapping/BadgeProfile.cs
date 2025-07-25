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
    public class BadgeProfile : Profile
    {
        public BadgeProfile()
        {
            CreateMap<Badge, BadgeResponse>();

            CreateMap<BadgeInsertRequest, Badge>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.UserBadges, opt => opt.Ignore())
                .ForMember(dest => dest.Rewards, opt => opt.Ignore());

            CreateMap<BadgeUpdateRequest, Badge>()
                .ForMember(dest => dest.UserBadges, opt => opt.Ignore())
                .ForMember(dest => dest.Rewards, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

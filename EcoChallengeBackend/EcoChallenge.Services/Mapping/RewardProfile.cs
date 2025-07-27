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
    public class RewardProfile : Profile
    {
        public RewardProfile()
        {
            CreateMap<Reward, RewardResponse>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Username : null))
                .ForMember(dest => dest.ApprovedByAdminName, opt => opt.MapFrom(src => src.ApprovedBy != null ? src.ApprovedBy.Username : null));

            CreateMap<RewardInsertRequest, Reward>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Request, opt => opt.Ignore())
                .ForMember(dest => dest.Event, opt => opt.Ignore())
                .ForMember(dest => dest.Donation, opt => opt.Ignore())
                .ForMember(dest => dest.RewardType, opt => opt.Ignore())
                .ForMember(dest => dest.Badge, opt => opt.Ignore())
                .ForMember(dest => dest.ApprovedBy, opt => opt.Ignore())
                .ForMember(dest => dest.ActivityLogs, opt => opt.Ignore())
                .ForMember(dest => dest.Notifications, opt => opt.Ignore());

            CreateMap<RewardUpdateRequest, Reward>()
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Request, opt => opt.Ignore())
                .ForMember(dest => dest.Event, opt => opt.Ignore())
                .ForMember(dest => dest.Donation, opt => opt.Ignore())
                .ForMember(dest => dest.RewardType, opt => opt.Ignore())
                .ForMember(dest => dest.Badge, opt => opt.Ignore())
                .ForMember(dest => dest.ApprovedBy, opt => opt.Ignore())
                .ForMember(dest => dest.ActivityLogs, opt => opt.Ignore())
                .ForMember(dest => dest.Notifications, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

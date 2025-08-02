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
    public class RequestParticipationProfile : Profile
    {
        public RequestParticipationProfile()
        {
            CreateMap<RequestParticipation, RequestParticipationResponse>()
                .ForMember(dest => dest.PhotoUrls, opt => opt.MapFrom(src => src.Photos != null
                    ? src.Photos.Select(p => p.ImageUrl).ToList()
                    : new List<string>()));

            CreateMap<RequestParticipationInsertRequest, RequestParticipation>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Photos, opt => opt.Ignore())
                .ForMember(dest => dest.SubmittedAt, opt => opt.Ignore());

            CreateMap<RequestParticipationUpdateRequest, RequestParticipation>()
                .ForMember(dest => dest.Photos, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

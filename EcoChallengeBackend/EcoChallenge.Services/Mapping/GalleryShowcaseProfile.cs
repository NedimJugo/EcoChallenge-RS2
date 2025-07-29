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
    public class GalleryShowcaseProfile : Profile
    {
        public GalleryShowcaseProfile()
        {
            CreateMap<GalleryShowcase, GalleryShowcaseResponse>();

            CreateMap<GalleryShowcaseInsertRequest, GalleryShowcase>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.LikesCount, opt => opt.Ignore())
                .ForMember(dest => dest.DislikesCount, opt => opt.Ignore())
                .ForMember(dest => dest.ReportCount, opt => opt.Ignore())
                .ForMember(dest => dest.IsApproved, opt => opt.Ignore())
                .ForMember(dest => dest.IsReported, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore());

            CreateMap<GalleryShowcaseUpdateRequest, GalleryShowcase>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }

}

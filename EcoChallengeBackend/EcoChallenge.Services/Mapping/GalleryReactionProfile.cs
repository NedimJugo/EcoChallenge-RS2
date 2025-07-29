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
    public class GalleryReactionProfile : Profile
    {
        public GalleryReactionProfile()
        {
            CreateMap<GalleryReaction, GalleryReactionResponse>();

            CreateMap<GalleryReactionInsertRequest, GalleryReaction>()
                .ForMember(dest => dest.Id, opt => opt.Ignore());

            CreateMap<GalleryReactionUpdateRequest, GalleryReaction>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }

}

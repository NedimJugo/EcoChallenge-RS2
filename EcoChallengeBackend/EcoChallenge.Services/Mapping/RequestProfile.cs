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
    public class RequestProfile : Profile
    {
        public RequestProfile()
        {
            CreateMap<Request, RequestResponse>()
                .ForMember(dest => dest.PhotoUrls,
                       opt => opt.MapFrom(src => src.Photos != null
                           ? src.Photos.Select(p => p.ImageUrl).ToList()
                           : new List<string>()));

            CreateMap<RequestInsertRequest, Request>()
                .ForMember(r => r.Id, o => o.Ignore())
                .ForMember(r => r.CreatedAt, o => o.Ignore())
                .ForMember(r => r.UpdatedAt, o => o.Ignore());

            CreateMap<RequestUpdateRequest, Request>()
              .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}


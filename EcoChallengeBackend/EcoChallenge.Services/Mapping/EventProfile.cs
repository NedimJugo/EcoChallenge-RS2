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
    public class EventProfile : Profile
    {
        public EventProfile()
        {
            CreateMap<Event, EventResponse>()
                 .ForMember(dest => dest.PhotoUrls,
                       opt => opt.MapFrom(src => src.Photos != null
                           ? src.Photos.Select(p => p.ImageUrl).ToList()
                           : new List<string>()));

            CreateMap<EventInsertRequest, Event>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(dest => dest.Photos, opt => opt.Ignore())
                .ForMember(e => e.CreatedAt, o => o.Ignore())
                .ForMember(e => e.UpdatedAt, o => o.Ignore())
                .ForMember(e => e.CurrentParticipants, o => o.Ignore());

            CreateMap<EventUpdateRequest, Event>()
              .ForMember(dest => dest.Photos, opt => opt.Ignore())
              .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

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
    public class EventStatusProfile : Profile
    {
        public EventStatusProfile()
        {
            CreateMap<EventStatus, EventStatusResponse>();
            CreateMap<EventStatusInsertRequest, EventStatus>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.Events, o => o.Ignore());
            CreateMap<EventStatusUpdateRequest, EventStatus>()
                .ForMember(e => e.Events, o => o.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

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
    public class EventProfile: Profile
    {
        public EventProfile()
        {
            CreateMap<Event, EventResponse>();
            CreateMap<EventInsertRequest, Event>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.CreatedAt, o => o.Ignore())
                .ForMember(e => e.UpdatedAt, o => o.Ignore())
                .ForMember(e => e.CurrentParticipants, o => o.Ignore());

            CreateMap<EventUpdateRequest, Event>()
              .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

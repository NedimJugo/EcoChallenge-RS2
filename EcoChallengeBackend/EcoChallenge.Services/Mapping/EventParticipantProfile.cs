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
    public class EventParticipantProfile : Profile
    {
        public EventParticipantProfile()
        {
            CreateMap<EventParticipant, EventParticipantResponse>();

            CreateMap<EventParticipantInsertRequest, EventParticipant>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.JoinedAt, o => o.Ignore())
                .ForMember(e => e.Event, o => o.Ignore())
                .ForMember(e => e.User, o => o.Ignore());

            CreateMap<EventParticipantUpdateRequest, EventParticipant>()
                .ForMember(e => e.JoinedAt, o => o.Ignore())
                .ForMember(e => e.Event, o => o.Ignore())
                .ForMember(e => e.User, o => o.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

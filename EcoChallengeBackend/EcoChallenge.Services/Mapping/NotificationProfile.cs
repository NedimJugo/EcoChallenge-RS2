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
    public class NotificationProfile : Profile
    {
        public NotificationProfile()
        {
            CreateMap<Notification, NotificationResponse>();

            CreateMap<NotificationInsertRequest, Notification>()
                .ForMember(n => n.Id, o => o.Ignore())
                .ForMember(n => n.CreatedAt, o => o.MapFrom(_ => DateTime.UtcNow))
                .ForMember(n => n.IsRead, o => o.MapFrom(_ => false))
                .ForMember(n => n.ReadAt, o => o.Ignore());

            CreateMap<NotificationUpdateRequest, Notification>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

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
    public class EntityTypeProfile : Profile
    {
        public EntityTypeProfile()
        {
            CreateMap<EntityType, EntityTypeResponse>();
            CreateMap<EntityTypeInsertRequest, EntityType>()
                .ForMember(e => e.Id, o => o.Ignore());
            CreateMap<EntityTypeUpdateRequest, EntityType>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

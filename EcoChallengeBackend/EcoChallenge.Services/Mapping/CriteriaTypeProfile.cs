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
    public class CriteriaTypeProfile : Profile
    {
        public CriteriaTypeProfile()
        {
            CreateMap<CriteriaType, CriteriaTypeResponse>();
            CreateMap<CriteriaTypeInsertRequest, CriteriaType>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.Badges, o => o.Ignore());
            CreateMap<CriteriaTypeUpdateRequest, CriteriaType>()
                .ForMember(e => e.Badges, o => o.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

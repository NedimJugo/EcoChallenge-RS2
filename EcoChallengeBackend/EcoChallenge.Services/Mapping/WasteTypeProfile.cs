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
    public class WasteTypeProfile : Profile
    {
        public WasteTypeProfile()
        {
            CreateMap<WasteType, WasteTypeResponse>();
            CreateMap<WasteTypeInsertRequest, WasteType>().ForMember(x => x.Id, o => o.Ignore());
            CreateMap<WasteTypeUpdateRequest, WasteType>().ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

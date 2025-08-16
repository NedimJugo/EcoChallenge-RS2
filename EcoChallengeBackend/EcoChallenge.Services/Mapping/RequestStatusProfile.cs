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
    public class RequestStatusProfile : Profile
    {
        public RequestStatusProfile()
        {
            CreateMap<RequestStatus, RequestStatusResponse>();
            CreateMap<RequestStatusInsertRequest, RequestStatus>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.Requests, o => o.Ignore());
            CreateMap<RequestStatusUpdateRequest, RequestStatus>()
                .ForMember(e => e.Requests, o => o.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

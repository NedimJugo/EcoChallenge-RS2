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
    public class OrganizationProfile : Profile
    {
        public OrganizationProfile()
        {
            CreateMap<Organization, OrganizationResponse>();

            CreateMap<OrganizationInsertRequest, Organization>()
                .ForMember(o => o.Id, opt => opt.Ignore())
                .ForMember(o => o.CreatedAt, opt => opt.Ignore())
                .ForMember(o => o.UpdatedAt, opt => opt.Ignore());

            CreateMap<OrganizationUpdateRequest, Organization>()
                .ForMember(o => o.UpdatedAt, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

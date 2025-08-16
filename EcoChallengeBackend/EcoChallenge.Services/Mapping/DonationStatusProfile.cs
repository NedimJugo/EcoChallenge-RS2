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
    public class DonationStatusProfile : Profile
    {
        public DonationStatusProfile()
        {
            CreateMap<DonationStatus, DonationStatusResponse>();
            CreateMap<DonationStatusInsertRequest, DonationStatus>()
                .ForMember(e => e.Id, o => o.Ignore())
                .ForMember(e => e.Donations, o => o.Ignore());
            CreateMap<DonationStatusUpdateRequest, DonationStatus>()
                .ForMember(e => e.Donations, o => o.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

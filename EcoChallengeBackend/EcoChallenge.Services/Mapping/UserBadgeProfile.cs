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
    public class UserBadgeProfile : Profile
    {
        public UserBadgeProfile()
        {
            CreateMap<UserBadge, UserBadgeResponse>();
            CreateMap<UserBadgeInsertRequest, UserBadge>().ForMember(x => x.Id, o => o.Ignore());
        }
    }

}

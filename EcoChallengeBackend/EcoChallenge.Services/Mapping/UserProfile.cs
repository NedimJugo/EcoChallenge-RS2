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
    public class UserProfile: Profile
    {
        public UserProfile()
        {
            CreateMap<User, UserResponse>();

            CreateMap<UserInsertRequest, User>()
                .ForMember(u => u.PasswordHash, o => o.Ignore()); // keep PasswordHash out

            CreateMap<UserUpdateRequest, User>()
                  .ForMember(u => u.PasswordHash, o => o.Ignore())
                  .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}

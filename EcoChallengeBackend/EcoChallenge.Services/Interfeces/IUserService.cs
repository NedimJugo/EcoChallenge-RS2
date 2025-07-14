using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Services.BaseInterfaces;

namespace EcoChallenge.Services.Interfeces
{
    public interface IUserService: ICRUDService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<UserResponse?> AuthenticateUser(UserLoginRequest request, CancellationToken ct = default);
    }
}

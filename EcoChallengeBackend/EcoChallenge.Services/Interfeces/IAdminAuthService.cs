using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IAdminAuthService
    {
        Task<AdminLoginResponse?> AuthenticateAdminAsync(UserLoginRequest request, CancellationToken cancellationToken = default);
        Task<bool> IsUserAdminAsync(string username, CancellationToken cancellationToken = default);
        Task<AdminProfileResponse?> GetAdminProfileAsync(string username, CancellationToken cancellationToken = default);
    }
}

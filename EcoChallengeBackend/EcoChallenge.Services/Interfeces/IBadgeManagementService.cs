using EcoChallenge.Models.Responses;
using EcoChallenge.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IBadgeManagementService
    {
        Task CheckAndAwardBadgesAsync(int userId);
        Task CheckPointsBadgesAsync(int userId);
        Task CheckRequestsBadgesAsync(int userId);
        Task CheckEventsBadgesAsync(int userId);
        Task CheckParticipationBadgesAsync(int userId);
        Task<List<UserBadgeResponse>> GetUserBadgesAsync(int userId);
        Task InitializeDefaultBadgesAsync();
    }

}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IUserStatsService
    {
        Task UpdateUserPointsAsync(int userId, int points, CancellationToken cancellationToken = default);
        Task UpdateUserCleanupsAsync(int userId, int increment, CancellationToken cancellationToken = default);
        Task UpdateUserEventsOrganizedAsync(int userId, int increment, CancellationToken cancellationToken = default);
        Task UpdateUserEventsParticipatedAsync(int userId, int increment, CancellationToken cancellationToken = default);
        Task RecalculateUserStatsAsync(int userId, CancellationToken cancellationToken = default);
    }
}

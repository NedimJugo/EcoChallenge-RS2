using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseInterfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface INotificationService :
        ICRUDService<NotificationResponse, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        Task<List<NotificationResponse>> CreateBulkAsync(List<NotificationInsertRequest> requests, CancellationToken cancellationToken = default);
        Task<bool> MarkAsReadAsync(int notificationId, CancellationToken cancellationToken = default);
        Task<int> MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default);
    }
}

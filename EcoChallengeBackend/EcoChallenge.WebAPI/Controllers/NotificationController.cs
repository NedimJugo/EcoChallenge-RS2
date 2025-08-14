using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController :
        BaseCRUDController<NotificationResponse, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        private readonly INotificationService _notificationService;

        public NotificationController(INotificationService service) : base(service)
        {
            _notificationService = service;
        }

        [HttpPost("bulk")]
        public async Task<ActionResult<List<NotificationResponse>>> CreateBulkAsync(
            [FromBody] List<NotificationInsertRequest> requests,
            CancellationToken cancellationToken = default)
        {
            var result = await _notificationService.CreateBulkAsync(requests, cancellationToken);
            return Ok(result);
        }

        [HttpPatch("{notificationId}/mark-as-read")]
        public async Task<ActionResult<bool>> MarkAsReadAsync(
            [FromRoute] int notificationId,
            CancellationToken cancellationToken = default)
        {
            var result = await _notificationService.MarkAsReadAsync(notificationId, cancellationToken);
            if (!result)
            {
                return NotFound();
            }
            return Ok(result);
        }

        [HttpPatch("user/{userId}/mark-all-as-read")]
        public async Task<ActionResult<int>> MarkAllAsReadAsync(
            [FromRoute] int userId,
            CancellationToken cancellationToken = default)
        {
            var result = await _notificationService.MarkAllAsReadAsync(userId, cancellationToken);
            return Ok(result);
        }
    }
}
using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class NotificationService :
       BaseCRUDService<NotificationResponse, NotificationSearchObject, Notification, NotificationInsertRequest, NotificationUpdateRequest>,
       INotificationService
    {
        public NotificationService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
        }

        protected override IQueryable<Notification> ApplyFilter(IQueryable<Notification> query, NotificationSearchObject s)
        {
            if (s.UserId.HasValue)
                query = query.Where(n => n.UserId == s.UserId.Value);

            if (s.NotificationType.HasValue)
                query = query.Where(n => n.NotificationType == s.NotificationType.Value);

            if (s.IsRead.HasValue)
                query = query.Where(n => n.IsRead == s.IsRead.Value);

            if (s.IsPushed.HasValue)
                query = query.Where(n => n.IsPushed == s.IsPushed.Value);

            return query;
        }
    }
}

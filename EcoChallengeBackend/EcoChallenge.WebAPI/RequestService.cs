using AutoMapper;
using AutoMapper.QueryableExtensions;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class RequestService : BaseCRUDService<RequestResponse, RequestSearchObject, Request, RequestInsertRequest, RequestUpdateRequest>, IRequestService
    {
        private readonly EcoChallengeDbContext _db;

        public RequestService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;

        }

        protected override IQueryable<Request> ApplyFilter(IQueryable<Request> query, RequestSearchObject s)
        {
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                var t = s.Text.ToLower();
                query = query.Where(r =>
                    r.Title!.ToLower().Contains(t) ||
                    r.Description!.ToLower().Contains(t) ||
                    r.AdminNotes!.ToLower().Contains(t) ||
                    r.RejectionReason!.ToLower().Contains(t));
            }

            if (s.Status.HasValue)
                query = query.Where(r => r.StatusId == s.Status.Value);

            if (s.WasteTypeId.HasValue)
                query = query.Where(r => r.WasteTypeId == s.WasteTypeId.Value);

            if (s.UrgencyLevel.HasValue)
                query = query.Where(r => r.UrgencyLevel == s.UrgencyLevel.Value);

            if (s.EstimatedAmount.HasValue)
                query = query.Where(r => r.EstimatedAmount == s.EstimatedAmount.Value);

            if (s.LocationId.HasValue)
                query = query.Where(r => r.LocationId == s.LocationId.Value);

            if (s.UserId.HasValue)
                query = query.Where(r => r.UserId == s.UserId.Value);

            if (s.AssignedAdminId.HasValue)
                query = query.Where(r => r.AssignedAdminId == s.AssignedAdminId.Value);

            return query;
        }
    }
}

using AutoMapper;
using AutoMapper.QueryableExtensions;
using EcoChallenge.Models.Enums;
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
        private readonly IBlobService _blobService;

        public RequestService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService) : base(db, mapper)
        {
            _db = db;
            _blobService = blobService;
        }

        protected override IQueryable<Request> ApplyFilter(IQueryable<Request> query, RequestSearchObject s)
        {
            query = query
               .Include(r => r.User)
               .Include(r => r.Location)
               .Include(r => r.WasteType)
               .Include(r => r.Status)
               .Include(r => r.AssignedAdmin)
               .Include(r => r.Photos);
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                var t = s.Text.ToLower();
                query.Where(r =>
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


        public override async Task<RequestResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Requests
                .Include(r => r.User)
                .Include(r => r.Location)
                .Include(r => r.WasteType)
                .Include(r => r.Status)
                .Include(r => r.AssignedAdmin)
                .Include(r => r.Photos)
                .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }


        protected override async Task BeforeInsert(Request entity, RequestInsertRequest request, CancellationToken cancellationToken = default)
        {
            if (request.Photos != null && request.Photos.Any())
            {
                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.UserId,
                        PhotoType = PhotoType.General,
                        IsPrimary = entity.Photos.Count == 0
                    });
                }
            }

            await base.BeforeInsert(entity, request, cancellationToken);
        }

        protected override async Task BeforeUpdate(Request entity, RequestUpdateRequest request, CancellationToken cancellationToken = default)
        {
            if (request.Photos != null && request.Photos.Any())
            {
                var existingPhotos = await _context.Photos
                    .Where(p => p.RequestId == entity.Id)
                    .ToListAsync(cancellationToken);

                _context.Photos.RemoveRange(existingPhotos);

                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.UserId,
                        PhotoType = PhotoType.General,
                        IsPrimary = entity.Photos.Count == 0
                    });
                }
            }

            await base.BeforeUpdate(entity, request, cancellationToken);
        }


    }
}

using AutoMapper;
using EcoChallenge.Models.Enums;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class RequestParticipationService : BaseCRUDService<RequestParticipationResponse, RequestParticipationSearchObject, RequestParticipation, RequestParticipationInsertRequest, RequestParticipationUpdateRequest>, IRequestParticipationService
    {
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;

        public RequestParticipationService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService) : base(db, mapper)
        {
            _db = db;
            _blobService = blobService;
        }

        protected override IQueryable<RequestParticipation> ApplyFilter(IQueryable<RequestParticipation> query, RequestParticipationSearchObject search)
        {
            query = query
                .Include(x => x.Photos)
                .Include(x => x.User)
                .Include(x => x.Request);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.RequestId.HasValue)
                query = query.Where(x => x.RequestId == search.RequestId.Value);

            if (search.Status.HasValue)
                query = query.Where(x => x.Status == search.Status.Value);

            return query;
        }

        protected override async Task BeforeInsert(RequestParticipation entity, RequestParticipationInsertRequest request, CancellationToken cancellationToken = default)
        {
            entity.SubmittedAt = DateTime.UtcNow;

            if (request.Photos != null && request.Photos.Any())
            {
                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = request.UserId,
                        PhotoType = PhotoType.After,
                        IsPrimary = false
                    });
                }
            }

            await base.BeforeInsert(entity, request, cancellationToken);
        }

        protected override async Task BeforeUpdate(RequestParticipation entity, RequestParticipationUpdateRequest request, CancellationToken cancellationToken = default)
        {
            if (request.Photos != null && request.Photos.Any())
            {
                var existingPhotos = await _db.Photos
                    .Where(p => p.RequestId == entity.Id)
                    .ToListAsync(cancellationToken);

                _db.Photos.RemoveRange(existingPhotos);

                entity.Photos = new List<Photo>();
                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.UserId,
                        PhotoType = PhotoType.After,
                        IsPrimary = false
                    });
                }
            }

            await base.BeforeUpdate(entity, request, cancellationToken);
        }
    }
}

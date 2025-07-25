using AutoMapper;
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
    public class BadgeService : BaseCRUDService<BadgeResponse, BadgeSearchObject, Badge, BadgeInsertRequest, BadgeUpdateRequest>, IBadgeService
    {
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;

        public BadgeService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService)
            : base(db, mapper)
        {
            _db = db;
            _blobService = blobService;
        }

        protected override IQueryable<Badge> ApplyFilter(IQueryable<Badge> query, BadgeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));
            }

            if (search.BadgeTypeId.HasValue)
            {
                query = query.Where(x => x.BadgeTypeId == search.BadgeTypeId.Value);
            }

            return query;
        }


        protected override async Task BeforeInsert(Badge entity, BadgeInsertRequest request, CancellationToken cancellationToken = default)
        {
            if (request.IconUrl != null)
            {
                var url = await _blobService.UploadFileAsync(request.IconUrl);
                entity.IconUrl = url;
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(Badge entity, BadgeUpdateRequest request, CancellationToken cancellationToken = default)
        {
            if (request.IconUrl != null)
            {
                var url = await _blobService.UploadFileAsync(request.IconUrl);
                entity.IconUrl = url;
            }
        }
    }
}

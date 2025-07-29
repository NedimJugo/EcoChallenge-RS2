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
    public class GalleryShowcaseService : BaseCRUDService<
    GalleryShowcaseResponse,
    GalleryShowcaseSearchObject,
    GalleryShowcase,
    GalleryShowcaseInsertRequest,
    GalleryShowcaseUpdateRequest>, IGalleryShowcaseService
    {
        private readonly IBlobService _blobService;
        public GalleryShowcaseService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService)
            : base(db, mapper)
        {
            _blobService = blobService;
        }

        protected override IQueryable<GalleryShowcase> ApplyFilter(
            IQueryable<GalleryShowcase> query,
            GalleryShowcaseSearchObject search)
        {
            if (search.LocationId.HasValue)
                query = query.Where(g => g.LocationId == search.LocationId);

            if (search.CreatedByAdminId.HasValue)
                query = query.Where(g => g.CreatedByAdminId == search.CreatedByAdminId);

            if (search.IsApproved.HasValue)
                query = query.Where(g => g.IsApproved == search.IsApproved.Value);

            if (search.IsFeatured.HasValue)
                query = query.Where(g => g.IsFeatured == search.IsFeatured.Value);

            if (!string.IsNullOrWhiteSpace(search.Title))
                query = query.Where(g => g.Title!.ToLower().Contains(search.Title.ToLower()));

            return query;
        }

        protected override async Task BeforeInsert(GalleryShowcase entity, GalleryShowcaseInsertRequest request, CancellationToken cancellationToken = default)
        {
            entity.CreatedAt = DateTime.UtcNow;
            entity.IsApproved = true;
            entity.LikesCount = 0;
            entity.DislikesCount = 0;
            entity.ReportCount = 0;

            // Upload to blob
            entity.BeforeImageUrl = await _blobService.UploadFileAsync(request.BeforeImage);
            entity.AfterImageUrl = await _blobService.UploadFileAsync(request.AfterImage);
        }

        protected override async Task BeforeUpdate(GalleryShowcase entity, GalleryShowcaseUpdateRequest request, CancellationToken cancellationToken = default)
        {
            if (request.BeforeImage != null)
            {
                entity.BeforeImageUrl = await _blobService.UploadFileAsync(request.BeforeImage);
            }

            if (request.AfterImage != null)
            {
                entity.AfterImageUrl = await _blobService.UploadFileAsync(request.AfterImage);
            }
        }


    }

}

using AutoMapper;
using EcoChallenge.Models.Enums;
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
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Services
{
    public class GalleryReactionService : BaseCRUDService<
    GalleryReactionResponse,
    GalleryReactionSearchObject,
    GalleryReaction,
    GalleryReactionInsertRequest,
    GalleryReactionUpdateRequest>, IGalleryReactionService
    {
        private readonly EcoChallengeDbContext _db;

        public GalleryReactionService(EcoChallengeDbContext db, IMapper mapper)
            : base(db, mapper)
        {
            _db = db;
        }

        public override async Task<GalleryReactionResponse> CreateAsync(GalleryReactionInsertRequest request, CancellationToken cancellationToken = default)
        {
            var existing = await _db.GalleryReactions
                .FirstOrDefaultAsync(x => x.UserId == request.UserId && x.GalleryShowcaseId == request.GalleryShowcaseId, cancellationToken);

            if (existing != null)
                throw new Exception("User has already reacted. Use update.");

            var entity = _mapper.Map<GalleryReaction>(request);
            _db.GalleryReactions.Add(entity);

            await UpdateGalleryCounts(request.GalleryShowcaseId, request.ReactionType, null);
            await _db.SaveChangesAsync(cancellationToken);

            return _mapper.Map<GalleryReactionResponse>(entity);
        }

        public override async Task<GalleryReactionResponse?> UpdateAsync(int id, GalleryReactionUpdateRequest request, CancellationToken cancellationToken = default)
        {
            var entity = await _db.GalleryReactions.Include(x => x.GalleryShowcase).FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
            if (entity == null)
                return null;

            var oldType = entity.ReactionType;
            if (oldType == request.ReactionType)
                return _mapper.Map<GalleryReactionResponse>(entity); // no change

            entity.ReactionType = request.ReactionType;

            await UpdateGalleryCounts(entity.GalleryShowcaseId, request.ReactionType, oldType);
            await _db.SaveChangesAsync(cancellationToken);

            return _mapper.Map<GalleryReactionResponse>(entity);
        }

        private async Task UpdateGalleryCounts(int galleryShowcaseId, ReactionType newType, ReactionType? oldType)
        {
            var gallery = await _db.GalleryShowcases.FirstOrDefaultAsync(x => x.Id == galleryShowcaseId);
            if (gallery == null)
                throw new Exception("Gallery not found.");

            // Remove old
            if (oldType.HasValue)
            {
                if (oldType == ReactionType.Like) gallery.LikesCount--;
                else if (oldType == ReactionType.Dislike) gallery.DislikesCount--;
            }

            // Add new
            if (newType == ReactionType.Like) gallery.LikesCount++;
            else if (newType == ReactionType.Dislike) gallery.DislikesCount++;
        }

        protected override IQueryable<GalleryReaction> ApplyFilter(IQueryable<GalleryReaction> query, GalleryReactionSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);
            if (search.GalleryShowcaseId.HasValue)
                query = query.Where(x => x.GalleryShowcaseId == search.GalleryShowcaseId.Value);
            return query;
        }
    }

}

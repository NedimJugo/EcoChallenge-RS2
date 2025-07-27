using AutoMapper;
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
    public class DonationService : BaseCRUDService<DonationResponse, DonationSearchObject, Donation, DonationInsertRequest, DonationUpdateRequest>, IDonationService
    {
        private readonly EcoChallengeDbContext _db;

        public DonationService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<Donation> ApplyFilter(IQueryable<Donation> query, DonationSearchObject s)
        {
            query = query.Include(d => d.User).Include(d => d.Organization).Include(d => d.Status);

            if (s.UserId.HasValue)
                query = query.Where(d => d.UserId == s.UserId.Value);

            if (s.OrganizationId.HasValue)
                query = query.Where(d => d.OrganizationId == s.OrganizationId.Value);

            if (s.StatusId.HasValue)
                query = query.Where(d => d.StatusId == s.StatusId.Value);

            if (s.IsAnonymous.HasValue)
                query = query.Where(d => d.IsAnonymous == s.IsAnonymous.Value);

            if (s.MinAmount.HasValue)
                query = query.Where(d => d.Amount >= s.MinAmount.Value);

            if (s.MaxAmount.HasValue)
                query = query.Where(d => d.Amount <= s.MaxAmount.Value);

            return query;
        }
    }
}

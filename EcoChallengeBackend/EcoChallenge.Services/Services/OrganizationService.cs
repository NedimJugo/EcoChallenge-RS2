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
    public class OrganizationService : BaseCRUDService<OrganizationResponse, OrganizationSearchObject, Organization, OrganizationInsertRequest, OrganizationUpdateRequest>, IOrganizationService
    {
        private readonly EcoChallengeDbContext _db;

        public OrganizationService(EcoChallengeDbContext db, IMapper mapper)
            : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<Organization> ApplyFilter(IQueryable<Organization> query, OrganizationSearchObject s)
        {
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                var text = s.Text.ToLower();
                query = query.Where(o =>
                    o.Name!.ToLower().Contains(text) ||
                    o.Description!.ToLower().Contains(text) ||
                    o.Website!.ToLower().Contains(text) ||
                    o.ContactEmail!.ToLower().Contains(text) ||
                    o.ContactPhone!.ToLower().Contains(text));
            }

            if (s.IsVerified.HasValue)
                query = query.Where(o => o.IsVerified == s.IsVerified.Value);

            if (s.IsActive.HasValue)
                query = query.Where(o => o.IsActive == s.IsActive.Value);

            if (!string.IsNullOrWhiteSpace(s.Category))
                query = query.Where(o => o.Category == s.Category);

            return query;
        }
    }
}

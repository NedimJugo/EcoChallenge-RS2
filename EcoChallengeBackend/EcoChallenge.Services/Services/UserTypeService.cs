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
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Services
{
    public class UserTypeService : BaseCRUDService<UserTypeResponse, UserTypeSearchObject, UserType, UserTypeInsertRequest, UserTypeUpdateRequest>, IUserTypeService
    {
        private readonly EcoChallengeDbContext _db;

        public UserTypeService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<UserType> ApplyFilter(IQueryable<UserType> query, UserTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return query;
        }

        protected override async Task BeforeDelete(UserType entity, CancellationToken cancellationToken = default)
        {
            // Check if there are any users with this user type
            var hasUsers = await _db.Users.AnyAsync(u => u.UserTypeId == entity.Id, cancellationToken);

            if (hasUsers)
            {
                throw new InvalidOperationException($"Cannot delete user type '{entity.Name}' because it is being used by one or more users.");
            }

            await base.BeforeDelete(entity, cancellationToken);
        }
    }
}

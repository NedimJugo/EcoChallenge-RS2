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
    public class WasteTypeService : BaseCRUDService<WasteTypeResponse, WasteTypeSearchObject, WasteType, WasteTypeInsertRequest, WasteTypeUpdateRequest>, IWasteTypeService
    {
        private readonly EcoChallengeDbContext _db;

        public WasteTypeService(EcoChallengeDbContext db, IMapper mapper)
            : base(db, mapper)
        {
            _db = db;
        }

        protected override IQueryable<WasteType> ApplyFilter(IQueryable<WasteType> query, WasteTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return query;
        }

        protected override async Task BeforeDelete(WasteType entity, CancellationToken cancellationToken = default)
        {
            // Check if there are any users with this user type
            var hasWaste = await _db.Requests.AnyAsync(u => u.WasteTypeId == entity.Id, cancellationToken);


            if (hasWaste)
            {
                throw new InvalidOperationException($"Cannot delete waste type '{entity.Name}' because it is being used by one or more users.");
            }

            await base.BeforeDelete(entity, cancellationToken);
        }
    }
}

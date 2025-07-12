using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Services.Interfeces;
using System.Linq.Dynamic.Core;
using EcoChallenge.Services.BaseInterfaces;

namespace EcoChallenge.Services.Services
{
    public abstract class BaseService<T, TSearch, TEntity> :
        IService<T, TSearch> 
            where T : class 
            where TSearch : BaseSearchObject 
            where TEntity : class
    {
        private readonly EcoChallengeDbContext _context;
        protected readonly IMapper _mapper;

        public BaseService(EcoChallengeDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<Models.Responses.PagedResult<T>> GetAsync(TSearch search, CancellationToken cancellationToken = default)
        {
            var query = _context.Set<TEntity>().AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync(cancellationToken);
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * (search.PageSize ?? 20));
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }



            var list = await query.ToListAsync(cancellationToken);
            return new Models.Responses.PagedResult<T>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        public virtual async Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Set<TEntity>().FindAsync(new object[] { id }, cancellationToken);
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected virtual T MapToResponse(TEntity entity)
        {
            return _mapper.Map<T>(entity);
        }

    }
}

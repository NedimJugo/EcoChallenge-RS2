using AutoMapper;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.BaseServices
{
    public abstract class BaseCRUDService<T, TSearch, TEntity, TInsert, TUpdate>
    : BaseService<T, TSearch, TEntity>
        where T : class
        where TSearch : BaseSearchObject
        where TEntity : class, new()
        where TInsert : class
        where TUpdate : class
    {
        protected readonly EcoChallengeDbContext _context;

        public BaseCRUDService(EcoChallengeDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }


        public virtual async Task<T> CreateAsync(TInsert request, CancellationToken cancellationToken = default)
        {
            var entity = new TEntity();
            MapInsertToEntity(entity, request);
            _context.Set<TEntity>().Add(entity);

            await BeforeInsert(entity, request, cancellationToken);

            await _context.SaveChangesAsync(cancellationToken);
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeInsert(TEntity entity, TInsert request, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
        }


        protected virtual TEntity MapInsertToEntity(TEntity entity, TInsert request)
        {
            return _mapper.Map(request, entity);
        }

        public virtual async Task<T?> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Set<TEntity>().FindAsync(new object[] { id }, cancellationToken);
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request, cancellationToken);

            MapUpdateToEntity(entity, request);

            await _context.SaveChangesAsync(cancellationToken);
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeUpdate(TEntity entity, TUpdate request, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
        }

        protected virtual void MapUpdateToEntity(TEntity entity, TUpdate request)
        {
            _mapper.Map(request, entity);
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Set<TEntity>().FindAsync(new object[] { id }, cancellationToken);
            if (entity == null)
                return false;

            await BeforeDelete(entity, cancellationToken);

            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }

        protected virtual async Task BeforeDelete(TEntity entity, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
        }


    }
}

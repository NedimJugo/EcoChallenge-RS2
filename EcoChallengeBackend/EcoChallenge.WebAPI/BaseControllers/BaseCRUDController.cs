using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseInterfaces;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.BaseControllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseCRUDController<T, TSearch, TInsert, TUpdate>
            : BaseController<T, TSearch> where T : class where TSearch : BaseSearchObject, new() where TInsert : class where TUpdate : class
    {
        protected readonly ICRUDService<T, TSearch, TInsert, TUpdate> _crudService;

        public BaseCRUDController(ICRUDService<T, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _crudService = service;
        }

        [HttpPost]
        public virtual async Task<T> Create([FromBody] TInsert request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public virtual async Task<T?> Update(int id, [FromBody] TUpdate request)
        {
            return await _crudService.UpdateAsync(id, request);
        }

        [HttpDelete("{id}")]
        public virtual async Task<bool> Delete(int id)
        {
            return await _crudService.DeleteAsync(id);
        }
    }
}

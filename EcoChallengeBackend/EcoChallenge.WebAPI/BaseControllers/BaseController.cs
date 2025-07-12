using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseInterfaces;
using Microsoft.AspNetCore.Mvc;
using System.Linq.Dynamic.Core;

namespace EcoChallenge.WebAPI.BaseControllers
{
    [ApiController]
    [Route("[controller]")]

    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : BaseSearchObject, new()
    {
        protected readonly IService<T, TSearch> _service;

        public BaseController(IService<T, TSearch> service)
        {
            _service = service;
        }

        [HttpGet("")]
        public virtual async Task<Models.Responses.PagedResult<T>> Get([FromQuery] TSearch? search = null)
        {
            return await _service.GetAsync(search ?? new TSearch());
        }

        [HttpGet("{id}")]
        public virtual async Task<T?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}

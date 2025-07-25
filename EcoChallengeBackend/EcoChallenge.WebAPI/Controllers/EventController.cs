using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventController : BaseCRUDController<EventResponse, EventSearchObject, EventInsertRequest, EventUpdateRequest>
    {
        public EventController(IEventService service) : base(service)
        {
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<EventResponse> Create([FromForm] EventInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<EventResponse?> Update(int id, [FromForm] EventUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }

    }
}

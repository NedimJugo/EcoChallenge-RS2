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
    public class BadgeController : BaseCRUDController<BadgeResponse, BadgeSearchObject, BadgeInsertRequest, BadgeUpdateRequest>
    {
        public BadgeController(IBadgeService service) : base(service)
        {
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<BadgeResponse> Create([FromForm] BadgeInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<BadgeResponse?> Update(int id, [FromForm] BadgeUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }
    }
}

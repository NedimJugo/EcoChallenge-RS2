using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseInterfaces;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RequestParticipationController : BaseCRUDController<RequestParticipationResponse, RequestParticipationSearchObject, RequestParticipationInsertRequest, RequestParticipationUpdateRequest>
    {
        public RequestParticipationController(IRequestParticipationService service) : base(service) { }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<RequestParticipationResponse> Create([FromForm] RequestParticipationInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<RequestParticipationResponse?> Update(int id, [FromForm] RequestParticipationUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }
    }
}

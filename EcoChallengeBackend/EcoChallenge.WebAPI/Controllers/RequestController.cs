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
    public class RequestController : BaseCRUDController<RequestResponse, RequestSearchObject, RequestInsertRequest, RequestUpdateRequest>
    {
        public RequestController(IRequestService service) : base(service)
        {
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<RequestResponse> Create([FromForm] RequestInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<RequestResponse?> Update(int id, [FromForm] RequestUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }
    }
}

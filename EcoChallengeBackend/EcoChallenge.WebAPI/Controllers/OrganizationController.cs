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
    public class OrganizationController : BaseCRUDController<OrganizationResponse, OrganizationSearchObject, OrganizationInsertRequest, OrganizationUpdateRequest>
    {
        public OrganizationController(IOrganizationService service) : base(service)
        {
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<OrganizationResponse> Create([FromForm] OrganizationInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<OrganizationResponse?> Update(int id, [FromForm] OrganizationUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }
    }
}

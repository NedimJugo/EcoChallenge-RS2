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
    public class GalleryShowcaseController : BaseCRUDController<
    GalleryShowcaseResponse,
    GalleryShowcaseSearchObject,
    GalleryShowcaseInsertRequest,
    GalleryShowcaseUpdateRequest>
    {
        public GalleryShowcaseController(IGalleryShowcaseService service) : base(service) { }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<GalleryShowcaseResponse> Create([FromForm] GalleryShowcaseInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<GalleryShowcaseResponse?> Update(int id, [FromForm] GalleryShowcaseUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }
    }


}

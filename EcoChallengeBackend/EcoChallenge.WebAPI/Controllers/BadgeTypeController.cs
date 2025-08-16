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
    public class BadgeTypeController : BaseCRUDController<BadgeTypeResponse, BadgeTypeSearchObject, BadgeTypeInsertRequest, BadgeTypeUpdateRequest>
    {
        public BadgeTypeController(IBadgeTypeService service) : base(service)
        {
        }
    }
}

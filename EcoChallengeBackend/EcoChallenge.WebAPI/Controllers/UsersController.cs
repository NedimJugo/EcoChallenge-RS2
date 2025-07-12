using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UsersController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UsersController(IUserService service) : base(service)
        {
        }
    }
}

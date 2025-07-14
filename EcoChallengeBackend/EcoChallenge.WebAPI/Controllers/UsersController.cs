using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Client;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UsersController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;
        public UsersController(IUserService service) : base(service)
        {
            _userService = service;
        }
        [HttpPost("login")]
        public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request, CancellationToken cancellationToken)
        {
            var user = await _userService.AuthenticateUser(request, cancellationToken);
            return Ok(user);
        }
    }
}

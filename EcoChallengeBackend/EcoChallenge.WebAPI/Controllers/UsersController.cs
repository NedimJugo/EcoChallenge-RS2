using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Client;
using System.Security.Claims;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;
        public UsersController(IUserService service) : base(service)
        {
            _userService = service;
        }
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request, CancellationToken cancellationToken)
        {
            var user = await _userService.AuthenticateUser(request, cancellationToken);
            return Ok(user);
        }


        [HttpGet("whoami")]
        public IActionResult WhoAmI()
        {
            var username = User.Identity?.Name;
            var role = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;

            return Ok(new
            {
                Username = username,
                Role = role
            });
        }

        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] UserInsertRequest request, CancellationToken ct)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var response = await _userService.RegisterAsync(request, ct);
                return CreatedAtAction(nameof(GetById), new { id = response.Id }, response);
            }
            catch (ArgumentException ex) // for validation errors like username/email exists
            {
                return Conflict(ex.Message);
            }
        }
        [AllowAnonymous]
        [HttpPost("admin-login")]
        public async Task<ActionResult<UserResponse>> AdminLogin(UserLoginRequest request, CancellationToken cancellationToken)
        {
            var user = await _userService.AuthenticateAdmin(request, cancellationToken);
            return Ok(user);
        }


        [HttpPost]
        [Consumes("multipart/form-data")]
        public override Task<UserResponse> Create([FromForm] UserInsertRequest request)
        {
            return base.Create(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override Task<UserResponse?> Update(int id, [FromForm] UserUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request, CancellationToken ct)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var result = await _userService.RequestPasswordResetAsync(request, ct);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "An error occurred while processing your request." });
            }
        }

        [AllowAnonymous]
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request, CancellationToken ct)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var result = await _userService.ResetPasswordAsync(request, ct);
                if (result.Success)
                    return Ok(result);
                else
                    return BadRequest(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "An error occurred while processing your request." });
            }
        }
    }
}

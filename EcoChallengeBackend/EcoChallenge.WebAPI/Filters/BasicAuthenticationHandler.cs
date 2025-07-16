using EcoChallenge.Models.Requests;
using EcoChallenge.Services.Interfeces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace EcoChallenge.WebAPI.Filters
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private readonly IUserService _userService;

        public BasicAuthenticationHandler(
            IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger,
            UrlEncoder encoder,
            IUserService userService)
            : base(options, logger, encoder)
        {
            _userService = userService;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.TryGetValue("Authorization", out var rawHeader))
                return AuthenticateResult.NoResult();

            if (!AuthenticationHeaderValue.TryParse(rawHeader, out var header) ||
                !string.Equals(header.Scheme, "Basic", StringComparison.OrdinalIgnoreCase) ||
                string.IsNullOrWhiteSpace(header.Parameter))
            {
                return AuthenticateResult.Fail("Invalid Authorization header.");
            }

            // ➌ Safe base64 decode
            string? username;
            string? password;
            try
            {
                var credentialBytes = Convert.FromBase64String(header.Parameter);
                var parts = Encoding.UTF8.GetString(credentialBytes).Split(':', 2);
                username = parts.ElementAtOrDefault(0);
                password = parts.ElementAtOrDefault(1);
            }
            catch (FormatException)
            {
                return AuthenticateResult.Fail("Malformed Base64 credentials.");
            }

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                return AuthenticateResult.Fail("Username or password missing.");

            var user = await _userService.AuthenticateUser(new UserLoginRequest { Username = username, Password = password });

            if (user == null)
                return AuthenticateResult.Fail("Invalid credentials");

            var claims = new List<Claim> {
                new Claim(ClaimTypes.NameIdentifier, user.Username.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.GivenName, user.FirstName),
                new Claim(ClaimTypes.Surname, user.LastName),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.UserTypeName)
            };

            var identity = new ClaimsIdentity(claims, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);


            return AuthenticateResult.Success(ticket);
        }
    }
}

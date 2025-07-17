using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class AdminAuthService : IAdminAuthService
    {
        private readonly IUserService _userService;
        private readonly EcoChallengeDbContext _context;
        private readonly ILogger<AdminAuthService> _logger;

        public AdminAuthService(
            IUserService userService,
            EcoChallengeDbContext context,
            ILogger<AdminAuthService> logger)
        {
            _userService = userService;
            _context = context;
            _logger = logger;
        }

        public async Task<AdminLoginResponse?> AuthenticateAdminAsync(UserLoginRequest request, CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                {
                    _logger.LogWarning("Admin login attempt with empty credentials");
                    return null;
                }

                // Use existing user service to authenticate
                var user = await _userService.AuthenticateUser(request, cancellationToken);

                if (user == null)
                {
                    _logger.LogWarning("Admin login failed: Invalid credentials for username: {Username}", request.Username);
                    return null;
                }

                // Check if user is admin
                if (!string.Equals(user.UserTypeName, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    _logger.LogWarning("Admin login failed: User {Username} is not an admin (UserType: {UserType})",
                        request.Username, user.UserTypeName);
                    return null;
                }

                _logger.LogInformation("Admin login successful for username: {Username}", request.Username);

                return new AdminLoginResponse
                {
                    Id = user.Id,
                    Username = user.Username,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Email = user.Email,
                    UserTypeName = user.UserTypeName,
                    LoginTime = DateTime.UtcNow
                };
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Admin authentication was cancelled");
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during admin authentication for username: {Username}", request.Username);
                return null;
            }
        }

        public async Task<bool> IsUserAdminAsync(string username, CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(username))
                    return false;

                var user = await _context.Users
                    .Include(u => u.UserType)
                    .FirstOrDefaultAsync(u => u.Username == username, cancellationToken);

                return user?.UserType?.Name?.Equals("Admin", StringComparison.OrdinalIgnoreCase) == true;
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Admin check was cancelled for username: {Username}", username);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking admin status for username: {Username}", username);
                return false;
            }
        }

        public async Task<AdminProfileResponse?> GetAdminProfileAsync(string username, CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(username))
                    return null;

                var user = await _context.Users
                    .Include(u => u.UserType)
                    .FirstOrDefaultAsync(u => u.Username == username, cancellationToken);

                if (user == null || !string.Equals(user.UserType?.Name, "Admin", StringComparison.OrdinalIgnoreCase))
                    return null;

                return new AdminProfileResponse
                {
                    Id = user.Id,
                    Username = user.Username,
                    FirstName = user.FirstName ?? string.Empty,
                    LastName = user.LastName ?? string.Empty,
                    Email = user.Email ?? string.Empty,
                    UserTypeName = user.UserType.Name
                };
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Get admin profile was cancelled for username: {Username}", username);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting admin profile for username: {Username}", username);
                return null;
            }
        }
    }
}

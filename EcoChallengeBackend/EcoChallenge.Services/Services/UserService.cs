using AutoMapper;
using AutoMapper.QueryableExtensions;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Models.Enums;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.Services.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Models.Messages;

namespace EcoChallenge.Services.Services
{
    public class UserService : BaseCRUDService<UserResponse, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IPasswordHasher _hasher;
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;
        private readonly IRabbitMQService _rabbitMQService;

        public UserService(
            EcoChallengeDbContext db,
            IMapper mapper,
            IPasswordHasher hasher,
            IBlobService blobService,
            IRabbitMQService rabbitMQService
        ) : base(db, mapper)
        {
            _hasher = hasher;
            _db = db;
            _blobService = blobService;
            _rabbitMQService = rabbitMQService;
        }

        public override async Task<PagedResult<UserResponse>> GetAsync(UserSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = _db.Users.Include(u => u.UserType).AsQueryable();

            // Filter po Text (možeš proširiti kako želiš)
            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                string lowerText = search.Text.ToLower();
                query = query.Where(u =>
                    u.Username!.ToLower().Contains(lowerText) ||
                    u.FirstName!.ToLower().Contains(lowerText) ||
                    u.LastName!.ToLower().Contains(lowerText) ||
                    u.Email!.ToLower().Contains(lowerText));
            }

            // Filter po UserTypeId
            if (search.UserTypeId.HasValue)
            {
                query = query.Where(u => u.UserTypeId == search.UserTypeId.Value);
            }

            // Filter po IsActive
            if (search.IsActive.HasValue)
            {
                query = query.Where(u => u.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Email))
            {
                string lowerEmail = search.Email.ToLower();
                query = query.Where(u => u.Email != null && u.Email.ToLower() == lowerEmail);
            }


            // Filter po Country
            if (!string.IsNullOrWhiteSpace(search.Username))
            {
                string lowerUsername = search.Username.ToLower();
                query = query.Where(u => u.Username != null && u.Username.ToLower() == lowerUsername);
            }

            // Filter po City
            if (!string.IsNullOrWhiteSpace(search.City))
            {
                string lowerCity = search.City.ToLower();
                query = query.Where(u => u.City != null && u.City.ToLower() == lowerCity);
            }

            // Ukupni broj zapisa prije paginacije
            int totalCount = 0;
            if (search.IncludeTotalCount)
                totalCount = await query.CountAsync(cancellationToken);


            // Ako se želi dohvatiti sve bez paginacije
            if (!search.RetrieveAll)
            {
                int skip = (search.Page ?? 0) * (search.PageSize ?? 20);
                int take = search.PageSize ?? 20;
                query = query.Skip(skip).Take(take);
            }

            // Dohvati podatke
            var list = await query.ToListAsync(cancellationToken);

            // Mapiranje u response modele
            var resultList = _mapper.Map<List<UserResponse>>(list);

            // Vrati paginirani rezultat
            return new PagedResult<UserResponse>
            {
                Items = resultList,
                TotalCount = totalCount
            };
        }
        public override async Task<UserResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var userEntity = await _db.Users
                .Include(u => u.UserType)  // OVDE je ključ
                .FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

            if (userEntity == null)
                return null;

            return _mapper.Map<UserResponse>(userEntity);
        }

        public override async Task<UserResponse> CreateAsync(UserInsertRequest req, CancellationToken ct = default)
        {
            bool emailExists = await _db.Users.AnyAsync(u => u.Email == req.Email, ct);
            if (emailExists)
                throw new ArgumentException("A user with this email already exists.");

            var entity = _mapper.Map<User>(req);
            entity.PasswordHash = _hasher.Hash(req.PasswordHash);

            if (req.ProfileImageUrl != null)
            {
                entity.ProfileImageUrl = await _blobService.UploadFileAsync(req.ProfileImageUrl);
            }

            _db.Add(entity);
            await _db.SaveChangesAsync(ct);

            return _mapper.Map<UserResponse>(entity);
        }

        public override async Task<UserResponse?> UpdateAsync(int id, UserUpdateRequest req, CancellationToken ct = default)
        {
            var entity = await _db.Users.FindAsync(new object[] { id }, ct);
            if (entity is null) return null;

            // Only update fields if provided
            if (!string.IsNullOrWhiteSpace(req.Username))
                entity.Username = req.Username;

            if (!string.IsNullOrWhiteSpace(req.Email))
                entity.Email = req.Email;

            if (!string.IsNullOrWhiteSpace(req.FirstName))
                entity.FirstName = req.FirstName;

            if (!string.IsNullOrWhiteSpace(req.LastName))
                entity.LastName = req.LastName;

            if (req.UserTypeId.HasValue)
                entity.UserTypeId = req.UserTypeId.Value;

            if (req.IsActive.HasValue)
                entity.IsActive = req.IsActive.Value;

            if (!string.IsNullOrWhiteSpace(req.PasswordHash))
                entity.PasswordHash = _hasher.Hash(req.PasswordHash);

            if (req.ProfileImageUrl != null)
                entity.ProfileImageUrl = await _blobService.UploadFileAsync(req.ProfileImageUrl);

            entity.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(ct);
            return _mapper.Map<UserResponse>(entity);
        }


        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject s)
        {
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                var t = s.Text.ToLower();
                query = query.Where(u =>
                    u.Username!.ToLower().Contains(t) ||
                    u.Email!.ToLower().Contains(t) ||
                    u.FirstName!.ToLower().Contains(t) ||
                    u.LastName!.ToLower().Contains(t));
            }

            if (s.UserTypeId.HasValue)
                query = query.Where(u => u.UserTypeId == s.UserTypeId.Value);

            if (s.IsActive.HasValue)
                query = query.Where(u => u.IsActive == s.IsActive.Value);

            if (!string.IsNullOrWhiteSpace(s.Country))
                query = query.Where(u => u.Country != null && u.Country.ToLower().Contains(s.Country.ToLower()));

            if (!string.IsNullOrWhiteSpace(s.City))
                query = query.Where(u => u.City != null && u.City.ToLower().Contains(s.City.ToLower()));

            return query;
        }

        public async Task<UserResponse?> AuthenticateUser(UserLoginRequest request, CancellationToken ct = default)
        {
            var user = await _db.Users
                .Include(u => u.UserType)
                .FirstOrDefaultAsync(u => u.Username == request.Username, ct);
            if (user == null || string.IsNullOrEmpty(user.PasswordHash))
                return null;

            if (!_hasher.Verify(request.Password, user.PasswordHash))
                return null;

            return MapToResponse(user);
        }

        public async Task<UserResponse> AuthenticateAdmin(UserLoginRequest request, CancellationToken ct)
        {
            var user = await _context.Users
                .Include(u => u.UserType)
                .FirstOrDefaultAsync(u =>
                    u.Username.ToLower() == request.Username.ToLower(), ct);

            if (user == null)
                throw new Exception("User not found");

            if (!_hasher.Verify(request.Password, user.PasswordHash))
                return null;

            if (user.UserType?.Name?.ToLower() != "admin")
                throw new Exception("Access denied. Not an admin user.");

            user.LastLogin = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);

            return MapToResponse(user);
        }


        public async Task<UserResponse> RegisterAsync(UserInsertRequest request, CancellationToken ct)
        {
            bool usernameExists = await _db.Users.AnyAsync(u => u.Username == request.Username, ct);
            if (usernameExists)
                throw new ArgumentException("Username already exists.");

            bool emailExists = await _db.Users.AnyAsync(u => u.Email == request.Email, ct);
            if (emailExists)
                throw new ArgumentException("Email already exists.");

            var userEntity = _mapper.Map<User>(request);
            userEntity.PasswordHash = _hasher.Hash(request.PasswordHash);

            _db.Users.Add(userEntity);
            await _db.SaveChangesAsync(ct);

            return _mapper.Map<UserResponse>(userEntity);
        }

        public async Task<ForgotPasswordResponse> RequestPasswordResetAsync(ForgotPasswordRequest request, CancellationToken ct = default)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.Email, ct);
            if (user == null)
            {
                // Don't reveal that email doesn't exist for security
                return new ForgotPasswordResponse
                {
                    Success = true,
                    Message = "If the email exists, a reset code has been sent."
                };
            }

            // Deactivate any existing reset codes for this user
            var existingResets = await _db.PasswordResets
                .Where(pr => pr.UserId == user.Id && !pr.IsUsed && pr.ExpiresAt > DateTime.UtcNow)
                .ToListAsync(ct);

            foreach (var reset in existingResets)
            {
                reset.IsUsed = true;
                reset.UsedAt = DateTime.UtcNow;
            }

            // Generate 6-digit reset code
            var resetCode = GenerateResetCode();
            var expiresAt = DateTime.UtcNow.AddMinutes(15); // 15 minutes expiry

            var passwordReset = new PasswordReset
            {
                UserId = user.Id,
                Email = user.Email,
                ResetCode = resetCode,
                ExpiresAt = expiresAt
            };

            _db.PasswordResets.Add(passwordReset);
            await _db.SaveChangesAsync(ct);

            // Publish message to RabbitMQ for email sending
            var message = new PasswordResetRequested
            {
                UserId = user.Id,
                UserName = $"{user.FirstName} {user.LastName}",
                UserEmail = user.Email,
                ResetCode = resetCode,
                RequestedAt = DateTime.UtcNow,
                ExpiresAt = expiresAt
            };

            // Assuming you have IRabbitMQService injected
            await _rabbitMQService.PublishAsync(message, "password.reset.requested");

            return new ForgotPasswordResponse
            {
                Success = true,
                Message = "Reset code has been sent to your email."
            };
        }

        public async Task<ForgotPasswordResponse> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken ct = default)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.Email, ct);
            if (user == null)
            {
                return new ForgotPasswordResponse
                {
                    Success = false,
                    Message = "Invalid reset code or email."
                };
            }

            var passwordReset = await _db.PasswordResets
                .FirstOrDefaultAsync(pr =>
                    pr.UserId == user.Id &&
                    pr.Email == request.Email &&
                    pr.ResetCode == request.ResetCode &&
                    !pr.IsUsed &&
                    pr.ExpiresAt > DateTime.UtcNow, ct);

            if (passwordReset == null)
            {
                return new ForgotPasswordResponse
                {
                    Success = false,
                    Message = "Invalid or expired reset code."
                };
            }

            // Update password
            user.PasswordHash = _hasher.Hash(request.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            // Mark reset code as used
            passwordReset.IsUsed = true;
            passwordReset.UsedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(ct);

            return new ForgotPasswordResponse
            {
                Success = true,
                Message = "Password has been reset successfully."
            };
        }

        private string GenerateResetCode()
        {
            var random = new Random();
            return random.Next(100000, 999999).ToString(); // 6-digit code
        }

    }
}

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

namespace EcoChallenge.Services.Services
{
    public class UserService : BaseCRUDService<UserResponse, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IPasswordHasher _hasher;
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;

        public UserService(
            EcoChallengeDbContext db,
            IMapper mapper,
            IPasswordHasher hasher,
            IBlobService blobService
        ) : base(db, mapper)
        {
            _hasher = hasher;
            _db = db;
            _blobService = blobService;
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

            // Filter po Country
            if (!string.IsNullOrWhiteSpace(search.Country))
            {
                string lowerCountry = search.Country.ToLower();
                query = query.Where(u => u.Country != null && u.Country.ToLower() == lowerCountry);
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

            _mapper.Map(req, entity);

            if (!string.IsNullOrWhiteSpace(req.PasswordHash))
                entity.PasswordHash = _hasher.Hash(req.PasswordHash);
            if (req.ProfileImageUrl != null)
            {
                entity.ProfileImageUrl = await _blobService.UploadFileAsync(req.ProfileImageUrl);
            }

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

    }
}

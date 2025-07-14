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

        public UserService(
            EcoChallengeDbContext db,
            IMapper mapper,
            IPasswordHasher hasher
        ) : base(db, mapper)
        {
            _hasher = hasher;
            _db = db;
        }

        public override async Task<UserResponse> CreateAsync(UserInsertRequest req, CancellationToken ct = default)
        {
            bool emailExists = await _db.Users.AnyAsync(u => u.Email == req.Email, ct);
            if (emailExists)
                throw new ArgumentException("A user with this email already exists.");

            var entity = _mapper.Map<User>(req);
            entity.PasswordHash = _hasher.Hash(req.PasswordHash);

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

            entity.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(ct);
            return _mapper.Map<UserResponse>(entity);
        }

        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject s)
        {
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                string t = s.Text.ToLower();
                query = query.Where(u =>
                    u.Username!.ToLower().Contains(t) ||
                    u.FirstName!.ToLower().Contains(t) ||
                    u.LastName!.ToLower().Contains(t) ||
                    u.Email!.ToLower().Contains(t));
            }

            if (s.IsActive.HasValue)
                query = query.Where(u => u.IsActive == s.IsActive);

            if (!string.IsNullOrWhiteSpace(s.City))
                query = query.Where(u => u.City == s.City);

            if (!string.IsNullOrWhiteSpace(s.Country))
                query = query.Where(u => u.Country == s.Country);

            return query;
        }

        public async Task<UserResponse?> AuthenticateUser(UserLoginRequest request, CancellationToken ct = default)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == request.Username, ct);
            if (user == null || string.IsNullOrEmpty(user.PasswordHash))
                return null;

            if (!_hasher.Verify(request.Password, user.PasswordHash))
                return null;

            return MapToResponse(user);
        }

    }
}

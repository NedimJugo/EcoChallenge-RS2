using AutoMapper;
using AutoMapper.QueryableExtensions;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class RequestService: BaseCRUDService<RequestResponse, RequestSearchObject, Request, RequestInsertRequest, RequestUpdateRequest>, IRequestService
    {
        private readonly EcoChallengeDbContext _db;

        public RequestService(EcoChallengeDbContext db, IMapper mapper) : base(db, mapper)
        {
            _db = db;

        }
    }
}

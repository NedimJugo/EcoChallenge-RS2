using EcoChallenge.Models;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ChallengeController : ControllerBase
    {

        protected readonly IChallengeService _challengeService;
        public ChallengeController(IChallengeService service)
        {
            _challengeService = service;
        }
        ChallengeService challengeService = new ChallengeService();
        [HttpGet("")]
        public IEnumerable<Challenge> Get([FromQuery]ChallengeSearchObject? search)
        {
            return challengeService.Get(search);
        }

        [HttpGet("{id}")]
        public Challenge Get(int id)
        {
            return challengeService.Get(id);
        }
    }
}

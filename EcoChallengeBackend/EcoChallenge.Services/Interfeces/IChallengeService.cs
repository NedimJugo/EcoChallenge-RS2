using EcoChallenge.Models;
using EcoChallenge.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IChallengeService
    {
        public List<Challenge> Get(ChallengeSearchObject search);
         public Challenge Get(int id);

    }
}

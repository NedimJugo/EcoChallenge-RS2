using EcoChallenge.Models;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Interfeces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class ChallengeService: IChallengeService
    {
        public virtual List<Challenge> Get(ChallengeSearchObject search)
        {
            List<Challenge> challenges = new List<Challenge>();
            challenges.Add(new Challenge()
            {
                Id = 1,
                Name = "Novi",
                Code = "111"
            });

            var queryable = challenges.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search?.Code))
            {
                queryable = queryable.Where(x => x.Code == search.Code);
            }

            if (!string.IsNullOrWhiteSpace(search?.CodeGTE))
            {
                queryable = queryable.Where(x => x.Code.StartsWith(search.CodeGTE));
            }

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                queryable = queryable.Where(x => x.Code.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase) || x.Name!=null && x.Name.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase));
            }
            return queryable.ToList();
        }
        public Challenge Get(int id)
        {
            return new Challenge()
            {
                Id = 1,
                Name = "Novi",
                Code = "111"
            };
        }
    }
}

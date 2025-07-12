using EcoChallenge.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.BaseInterfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<Models.Responses.PagedResult<T>> GetAsync(TSearch search, CancellationToken cancellationToken = default);
        Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    }
}

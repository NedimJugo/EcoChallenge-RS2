using EcoChallenge.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.BaseInterfaces
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> 
        where T : class 
        where TSearch : BaseSearchObject 
        where TInsert : class 
        where TUpdate : class
    {
        Task<T> CreateAsync(TInsert request, CancellationToken cancellationToken = default);
        Task<T?> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default);
        Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
    }
}

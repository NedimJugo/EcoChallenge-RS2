using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class BaseSearchObject
    {
        public int? Page { get; set; } = 0;
        public int? PageSize { get; set; } = 20;
        public string SortBy { get; set; } = "Id"; // or whatever is default
        public bool Desc { get; set; } = false;
        public bool IncludeTotalCount { get; set; } = true;
        public bool RetrieveAll { get; set; } = false;
    }
}

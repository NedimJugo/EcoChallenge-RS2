using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IBlobService
    {
        Task<string> UploadFileAsync(IFormFile file);
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Security
{
    public interface IPasswordHasher
    {
        /// <summary>Returns a PBKDF2 hash that already contains the iteration count and salt.</summary>
        string Hash(string password);

        /// <summary>Checks a plain password against a previously‑produced hash.</summary>
        bool Verify(string password, string storedHash);
    }
}

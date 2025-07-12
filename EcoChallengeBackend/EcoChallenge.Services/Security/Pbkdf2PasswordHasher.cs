using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Security
{
    public sealed class Pbkdf2PasswordHasher: IPasswordHasher
    {
        private const int Iterations = 100_000;   // OWASP ≥ 100 000  (configurable)
        private const int SaltSize = 16;        // 128 bit
        private const int KeySize = 32;        // 256 bit

        public string Hash(string password)
        {
            // generate salt
            Span<byte> salt = stackalloc byte[SaltSize];
            RandomNumberGenerator.Fill(salt);

            // derive key
            byte[] key = Rfc2898DeriveBytes.Pbkdf2(
                password,
                salt,
                Iterations,
                HashAlgorithmName.SHA256,
                KeySize);

            // store as: <iter>.<saltB64>.<keyB64>
            return $"{Iterations}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(key)}";
        }

        public bool Verify(string password, string storedHash)
        {
            var parts = storedHash.Split('.', 3);
            if (parts.Length != 3) return false;

            int iter = int.Parse(parts[0]);
            byte[] salt = Convert.FromBase64String(parts[1]);
            byte[] key = Convert.FromBase64String(parts[2]);

            byte[] computed = Rfc2898DeriveBytes.Pbkdf2(
                password,
                salt,
                iter,
                HashAlgorithmName.SHA256,
                KeySize);

            // constant‑time comparison
            return CryptographicOperations.FixedTimeEquals(computed, key);
        }
    }
}

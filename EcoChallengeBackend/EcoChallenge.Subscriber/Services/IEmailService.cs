using EcoChallenge.Models.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Subscriber.Services
{
    public interface IEmailService
    {
        Task SendRequestStatusChangedEmailAsync(RequestStatusChanged message);
        Task SendProofStatusChangedEmailAsync(ProofStatusChanged message);
        Task SendPasswordResetEmailAsync(PasswordResetRequested message);
    }
}

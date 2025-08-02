using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IStripeService
    {
        Task<StripePaymentResponse> CreatePaymentIntentAsync(StripePaymentRequest request, CancellationToken cancellationToken = default);
        Task<StripePaymentResponse> ConfirmPaymentAsync(string paymentIntentId, CancellationToken cancellationToken = default);
        Task<bool> HandleWebhookAsync(string payload, string signature, CancellationToken cancellationToken = default);
        Task<StripeConfigResponse> GetConfigAsync();
    }
}

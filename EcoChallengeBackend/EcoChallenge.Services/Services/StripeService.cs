using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Stripe;

namespace EcoChallenge.Services.Services
{
    public class StripeService : IStripeService
    {
        private readonly IConfiguration _configuration;
        private readonly EcoChallengeDbContext _context;
        private readonly IMapper _mapper;
        private readonly ILogger<StripeService> _logger;
        private readonly string _stripeSecretKey;
        private readonly string _stripeWebhookSecret;

        public StripeService(
            IConfiguration configuration,
            EcoChallengeDbContext context,
            IMapper mapper,
            ILogger<StripeService> logger)
        {
            _configuration = configuration;
            _context = context;
            _mapper = mapper;
            _logger = logger;
            _stripeSecretKey = _configuration["Stripe:SecretKey"] ?? throw new InvalidOperationException("Stripe SecretKey not configured");
            _stripeWebhookSecret = _configuration["Stripe:WebhookSecret"] ?? throw new InvalidOperationException("Stripe WebhookSecret not configured");

            StripeConfiguration.ApiKey = _stripeSecretKey;
        }

        public async Task<StripePaymentResponse> CreatePaymentIntentAsync(StripePaymentRequest request, CancellationToken cancellationToken = default)
        {
            try
            {
                // Convert BAM to smallest currency unit (feninga)
                var amountInSmallestUnit = (long)(request.Amount * 100);

                // Create donation record first
                var donation = new Donation
                {
                    UserId = request.UserId,
                    OrganizationId = request.OrganizationId,
                    Amount = request.Amount,
                    Currency = request.Currency,
                    DonationMessage = request.DonationMessage,
                    IsAnonymous = request.IsAnonymous,
                    StatusId = 1, // Pending status
                    PaymentMethod = "stripe",
                    CreatedAt = DateTime.UtcNow
                };

                _context.Donations.Add(donation);
                await _context.SaveChangesAsync(cancellationToken);

                // Create Stripe PaymentIntent
                var options = new PaymentIntentCreateOptions
                {
                    Amount = amountInSmallestUnit,
                    Currency = request.Currency.ToLower(),
                    PaymentMethodTypes = new List<string> { "card" },
                    Metadata = new Dictionary<string, string>
                    {
                        { "donation_id", donation.Id.ToString() },
                        { "user_id", request.UserId.ToString() },
                        { "organization_id", request.OrganizationId.ToString() }
                    },
                    Description = $"Donation to organization {request.OrganizationId}",
                };

                var service = new PaymentIntentService();
                var paymentIntent = await service.CreateAsync(options, cancellationToken: cancellationToken);

                // Update donation with Stripe PaymentIntent ID
                donation.StripePaymentIntentId = paymentIntent.Id;
                donation.StripePaymentStatus = paymentIntent.Status;
                await _context.SaveChangesAsync(cancellationToken);

                return new StripePaymentResponse
                {
                    PaymentIntentId = paymentIntent.Id,
                    ClientSecret = paymentIntent.ClientSecret,
                    Status = paymentIntent.Status,
                    Amount = request.Amount,
                    Currency = request.Currency,
                    DonationId = donation.Id
                };
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Stripe error creating payment intent");
                throw new Exception($"Payment processing error: {ex.Message}");
            }
        }

        public async Task<StripePaymentResponse> ConfirmPaymentAsync(string paymentIntentId, CancellationToken cancellationToken = default)
        {
            try
            {
                var service = new PaymentIntentService();
                var paymentIntent = await service.GetAsync(paymentIntentId, cancellationToken: cancellationToken);

                var donation = await _context.Donations
                    .FirstOrDefaultAsync(d => d.StripePaymentIntentId == paymentIntentId, cancellationToken);

                if (donation != null)
                {
                    donation.StripePaymentStatus = paymentIntent.Status;
                    if (paymentIntent.Status == "succeeded")
                    {
                        donation.StatusId = 2; // Completed status
                        donation.ProcessedAt = DateTime.UtcNow;
                        donation.PaymentReference = paymentIntent.Id;
                        donation.PointsEarned = CalculatePoints(donation.Amount);
                    }
                    await _context.SaveChangesAsync(cancellationToken);
                }

                return new StripePaymentResponse
                {
                    PaymentIntentId = paymentIntent.Id,
                    ClientSecret = paymentIntent.ClientSecret,
                    Status = paymentIntent.Status,
                    Amount = (decimal)paymentIntent.Amount / 100,
                    Currency = paymentIntent.Currency.ToUpper(),
                    DonationId = donation?.Id ?? 0
                };
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Stripe error confirming payment");
                throw new Exception($"Payment confirmation error: {ex.Message}");
            }
        }

        public async Task<bool> HandleWebhookAsync(string payload, string signature, CancellationToken cancellationToken = default)
        {
            try
            {
                var stripeEvent = EventUtility.ConstructEvent(payload, signature, _stripeWebhookSecret);

                // Use string constants instead of Events class
                if (stripeEvent.Type == "payment_intent.succeeded")
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntent != null)
                    {
                        var donation = await _context.Donations
                            .FirstOrDefaultAsync(d => d.StripePaymentIntentId == paymentIntent.Id, cancellationToken);

                        if (donation != null)
                        {
                            donation.StripePaymentStatus = paymentIntent.Status;
                            donation.StatusId = 2; // Completed
                            donation.ProcessedAt = DateTime.UtcNow;
                            donation.PaymentReference = paymentIntent.Id;
                            donation.PointsEarned = CalculatePoints(donation.Amount);
                            await _context.SaveChangesAsync(cancellationToken);
                        }
                    }
                }
                else if (stripeEvent.Type == "payment_intent.payment_failed")
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntent != null)
                    {
                        var donation = await _context.Donations
                            .FirstOrDefaultAsync(d => d.StripePaymentIntentId == paymentIntent.Id, cancellationToken);

                        if (donation != null)
                        {
                            donation.StripePaymentStatus = paymentIntent.Status;
                            donation.StatusId = 3; // Failed
                            await _context.SaveChangesAsync(cancellationToken);
                        }
                    }
                }

                return true;
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Webhook signature verification failed");
                return false;
            }
        }

        public async Task<StripeConfigResponse> GetConfigAsync()
        {
            return new StripeConfigResponse
            {
                PublishableKey = _configuration["Stripe:PublishableKey"] ?? throw new InvalidOperationException("Stripe PublishableKey not configured")
            };
        }

        private int CalculatePoints(decimal amount)
        {
            // 1 point per BAM donated
            return (int)Math.Floor(amount);
        }
    }
}
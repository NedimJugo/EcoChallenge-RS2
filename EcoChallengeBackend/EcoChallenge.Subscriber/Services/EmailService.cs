using EcoChallenge.Models.Messages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Subscriber.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendRequestStatusChangedEmailAsync(RequestStatusChanged message)
        {
            try
            {
                _logger.LogInformation("Starting to send request status email to {Email} for Request {RequestId}",
                    message.UserEmail, message.RequestId);

                // Validate message data
                if (string.IsNullOrEmpty(message.UserEmail))
                {
                    _logger.LogError("Cannot send email: UserEmail is null or empty for Request {RequestId}", message.RequestId);
                    return;
                }

                if (!IsValidEmail(message.UserEmail))
                {
                    _logger.LogError("Cannot send email: Invalid email format {Email} for Request {RequestId}",
                        message.UserEmail, message.RequestId);
                    return;
                }

                var subject = $"EcoChallenge: Your request \"{message.RequestTitle}\" has been {message.NewStatus.ToLower()}";
                var body = GenerateRequestStatusEmailBody(message);

                _logger.LogInformation("Sending request status email with subject: {Subject}", subject);

                await SendEmailAsync(message.UserEmail, message.UserName, subject, body);

                _logger.LogInformation("✅ Request status email sent successfully to {Email} for Request {RequestId}",
                    message.UserEmail, message.RequestId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Failed to send request status email to {Email} for Request {RequestId}",
                    message.UserEmail, message.RequestId);
                throw;
            }
        }

        public async Task SendProofStatusChangedEmailAsync(ProofStatusChanged message)
        {
            try
            {
                _logger.LogInformation("Starting to send proof status email to {Email} for Participation {ParticipationId}",
                    message.UserEmail, message.ParticipationId);

                // Validate message data
                if (string.IsNullOrEmpty(message.UserEmail))
                {
                    _logger.LogError("Cannot send email: UserEmail is null or empty for Participation {ParticipationId}",
                        message.ParticipationId);
                    return;
                }

                if (!IsValidEmail(message.UserEmail))
                {
                    _logger.LogError("Cannot send email: Invalid email format {Email} for Participation {ParticipationId}",
                        message.UserEmail, message.ParticipationId);
                    return;
                }

                var subject = $"EcoChallenge: Your proof submission for \"{message.RequestTitle}\" has been {message.NewStatus.ToLower()}";
                var body = GenerateProofStatusEmailBody(message);

                _logger.LogInformation("Sending proof status email with subject: {Subject}", subject);

                await SendEmailAsync(message.UserEmail, message.UserName, subject, body);

                _logger.LogInformation("✅ Proof status email sent successfully to {Email} for Participation {ParticipationId}",
                    message.UserEmail, message.ParticipationId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Failed to send proof status email to {Email} for Participation {ParticipationId}",
                    message.UserEmail, message.ParticipationId);
                throw;
            }
        }

        private async Task SendEmailAsync(string toEmail, string toName, string subject, string body)
        {
            var fromEmail = _configuration["Email:FromEmail"] ?? "noreply@ecochallenge.com";
            var fromName = _configuration["Email:FromName"] ?? "EcoChallenge Team";
            var smtpHost = _configuration["Email:SmtpHost"] ?? "smtp.gmail.com";
            var smtpPort = int.Parse(_configuration["Email:SmtpPort"] ?? "587");
            var enableSsl = bool.Parse(_configuration["Email:EnableSsl"] ?? "true");
            var username = _configuration["Email:Username"];
            var password = _configuration["Email:Password"];

            _logger.LogInformation("Email configuration - Host: {Host}, Port: {Port}, SSL: {EnableSsl}, Username: {Username}, FromEmail: {FromEmail}",
                smtpHost, smtpPort, enableSsl, username, fromEmail);

            // Validate email configuration
            if (string.IsNullOrEmpty(username))
            {
                _logger.LogError("❌ Email Username is not configured in appsettings.json");
                throw new InvalidOperationException("Email Username is not configured");
            }

            if (string.IsNullOrEmpty(password))
            {
                _logger.LogError("❌ Email Password is not configured in appsettings.json");
                throw new InvalidOperationException("Email Password is not configured");
            }

            try
            {
                using var smtpClient = new SmtpClient
                {
                    Host = smtpHost,
                    Port = smtpPort,
                    EnableSsl = enableSsl,
                    Credentials = new NetworkCredential(username, password),
                    Timeout = 30000, // 30 seconds timeout
                    DeliveryMethod = SmtpDeliveryMethod.Network
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(fromEmail, fromName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true,
                    Priority = MailPriority.Normal
                };

                mailMessage.To.Add(new MailAddress(toEmail, toName ?? "User"));

                _logger.LogInformation("📧 Attempting SMTP connection to {Host}:{Port} with SSL={EnableSsl}",
                    smtpHost, smtpPort, enableSsl);

                // Test SMTP connection first
                await TestSmtpConnectionAsync(smtpClient);

                _logger.LogInformation("📧 Sending email to {ToEmail} with subject: {Subject}", toEmail, subject);

                await smtpClient.SendMailAsync(mailMessage);

                _logger.LogInformation("✅ Email sent successfully to {ToEmail}", toEmail);
            }
            catch (SmtpException smtpEx)
            {
                _logger.LogError(smtpEx, "❌ SMTP Error: {StatusCode} - {Message}",
                    smtpEx.StatusCode, smtpEx.Message);

                // Log specific SMTP error details
                switch (smtpEx.StatusCode)
                {
                    case SmtpStatusCode.MailboxBusy:
                        _logger.LogWarning("SMTP server is busy, consider retrying");
                        break;
                    case SmtpStatusCode.InsufficientStorage:
                        _logger.LogWarning("SMTP server storage full");
                        break;
                    case SmtpStatusCode.TransactionFailed:
                        _logger.LogError("SMTP transaction failed - check credentials");
                        break;
                    case SmtpStatusCode.CommandNotImplemented:
                        _logger.LogError("SMTP command not supported by server");
                        break;
                }

                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ General error sending email to {ToEmail}", toEmail);
                throw;
            }
        }

        private async Task TestSmtpConnectionAsync(SmtpClient smtpClient)
        {
            try
            {
                // Create a test message to verify connection
                var testMessage = new MailMessage
                {
                    From = new MailAddress(_configuration["Email:FromEmail"] ?? "test@test.com"),
                    Subject = "Connection Test",
                    Body = "Test",
                    IsBodyHtml = false
                };
                testMessage.To.Add("test@test.com");

                // This will test the connection without actually sending
                _logger.LogDebug("Testing SMTP connection...");

                // Note: We're not actually sending this test message
                // SmtpClient will establish connection during SendMailAsync

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ SMTP connection test failed");
                throw;
            }
        }

        private bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            try
            {
                var mailAddress = new MailAddress(email);
                return mailAddress.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private string GenerateRequestStatusEmailBody(RequestStatusChanged message)
        {
            var statusColor = message.NewStatus.ToLower() == "approved" ? "#28a745" : "#dc3545";
            var statusIcon = message.NewStatus.ToLower() == "approved" ? "✅" : "❌";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Request Status Update</title>
</head>
<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
            <h1 style='color: #2c3e50; margin-bottom: 10px;'>
                {statusIcon} Request Status Update
            </h1>
            <p style='font-size: 16px; margin: 0;'>
                Hello {message.UserName},
            </p>
        </div>

        <div style='background-color: white; padding: 20px; border: 1px solid #dee2e6; border-radius: 8px;'>
            <h2 style='color: {statusColor}; margin-top: 0;'>
                Your request has been {message.NewStatus.ToLower()}
            </h2>
            
            <div style='margin-bottom: 15px;'>
                <strong>Request:</strong> {message.RequestTitle}
            </div>
            
            <div style='margin-bottom: 15px;'>
                <strong>Status:</strong> 
                <span style='color: {statusColor}; font-weight: bold;'>{message.NewStatus}</span>
            </div>

            {(message.NewStatus.ToLower() == "approved" && (message.ActualRewardPoints > 0 || message.ActualRewardMoney > 0) ? $@"
            <div style='background-color: #d4edda; padding: 15px; border-radius: 5px; margin: 15px 0;'>
                <h3 style='color: #155724; margin-top: 0;'>🎉 Congratulations! You've earned rewards:</h3>
                {(message.ActualRewardPoints > 0 ? $"<p><strong>Points:</strong> {message.ActualRewardPoints}</p>" : "")}
                {(message.ActualRewardMoney > 0 ? $"<p><strong>Money:</strong> ${message.ActualRewardMoney:F2}</p>" : "")}
            </div>" : "")}

            {(!string.IsNullOrEmpty(message.AdminNotes) ? $@"
            <div style='margin-bottom: 15px;'>
                <strong>Admin Notes:</strong>
                <p style='background-color: #f8f9fa; padding: 10px; border-radius: 4px; margin: 5px 0;'>
                    {message.AdminNotes}
                </p>
            </div>" : "")}

            {(!string.IsNullOrEmpty(message.RejectionReason) ? $@"
            <div style='margin-bottom: 15px;'>
                <strong>Reason:</strong>
                <p style='background-color: #f8d7da; padding: 10px; border-radius: 4px; margin: 5px 0; color: #721c24;'>
                    {message.RejectionReason}
                </p>
            </div>" : "")}

            <div style='margin-top: 20px; padding-top: 20px; border-top: 1px solid #dee2e6; font-size: 14px; color: #6c757d;'>
                <p>Updated on: {message.ChangedAt:MMMM dd, yyyy 'at' HH:mm} UTC</p>
                {(!string.IsNullOrEmpty(message.AdminName) ? $"<p>Reviewed by: {message.AdminName}</p>" : "")}
            </div>
        </div>

        <div style='margin-top: 20px; text-align: center; font-size: 14px; color: #6c757d;'>
            <p>Thank you for participating in EcoChallenge!</p>
            <p>Together, we're making a difference for our environment. 🌱</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GenerateProofStatusEmailBody(ProofStatusChanged message)
        {
            var statusColor = message.NewStatus.ToLower() == "approved" ? "#28a745" : "#dc3545";
            var statusIcon = message.NewStatus.ToLower() == "approved" ? "✅" : "❌";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Proof Submission Status Update</title>
</head>
<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
            <h1 style='color: #2c3e50; margin-bottom: 10px;'>
                {statusIcon} Proof Submission Update
            </h1>
            <p style='font-size: 16px; margin: 0;'>
                Hello {message.UserName},
            </p>
        </div>

        <div style='background-color: white; padding: 20px; border: 1px solid #dee2e6; border-radius: 8px;'>
            <h2 style='color: {statusColor}; margin-top: 0;'>
                Your proof submission has been {message.NewStatus.ToLower()}
            </h2>
            
            <div style='margin-bottom: 15px;'>
                <strong>Request:</strong> {message.RequestTitle}
            </div>
            
            <div style='margin-bottom: 15px;'>
                <strong>Status:</strong> 
                <span style='color: {statusColor}; font-weight: bold;'>{message.NewStatus}</span>
            </div>

            {(message.NewStatus.ToLower() == "approved" && (message.RewardPoints > 0 || message.RewardMoney > 0) ? $@"
            <div style='background-color: #d4edda; padding: 15px; border-radius: 5px; margin: 15px 0;'>
                <h3 style='color: #155724; margin-top: 0;'>🎉 Congratulations! You've earned rewards:</h3>
                {(message.RewardPoints > 0 ? $"<p><strong>Points:</strong> {message.RewardPoints}</p>" : "")}
                {(message.RewardMoney > 0 ? $"<p><strong>Money:</strong> ${message.RewardMoney:F2}</p>" : "")}
                
                {(!string.IsNullOrEmpty(message.CardHolderName) || !string.IsNullOrEmpty(message.BankName) ? $@"
                <div style='margin-top: 10px; padding-top: 10px; border-top: 1px solid #c3e6cb;'>
                    <p style='margin: 5px 0;'><strong>Payment Details:</strong></p>
                    {(!string.IsNullOrEmpty(message.CardHolderName) ? $"<p style='margin: 2px 0;'>Account Holder: {message.CardHolderName}</p>" : "")}
                    {(!string.IsNullOrEmpty(message.BankName) ? $"<p style='margin: 2px 0;'>Bank: {message.BankName}</p>" : "")}
                    {(!string.IsNullOrEmpty(message.TransactionNumber) ? $"<p style='margin: 2px 0;'>Transaction: {message.TransactionNumber}</p>" : "")}
                </div>" : "")}
            </div>" : "")}

            {(!string.IsNullOrEmpty(message.AdminNotes) ? $@"
            <div style='margin-bottom: 15px;'>
                <strong>Admin Notes:</strong>
                <p style='background-color: #f8f9fa; padding: 10px; border-radius: 4px; margin: 5px 0;'>
                    {message.AdminNotes}
                </p>
            </div>" : "")}

            {(!string.IsNullOrEmpty(message.RejectionReason) ? $@"
            <div style='margin-bottom: 15px;'>
                <strong>Reason:</strong>
                <p style='background-color: #f8d7da; padding: 10px; border-radius: 4px; margin: 5px 0; color: #721c24;'>
                    {message.RejectionReason}
                </p>
            </div>" : "")}

            <div style='margin-top: 20px; padding-top: 20px; border-top: 1px solid #dee2e6; font-size: 14px; color: #6c757d;'>
                <p>Updated on: {message.ChangedAt:MMMM dd, yyyy 'at' HH:mm} UTC</p>
                {(!string.IsNullOrEmpty(message.AdminName) ? $"<p>Reviewed by: {message.AdminName}</p>" : "")}
            </div>
        </div>

        <div style='margin-top: 20px; text-align: center; font-size: 14px; color: #6c757d;'>
            <p>Thank you for your participation in EcoChallenge!</p>
            <p>Your efforts are making a real difference! 🌍</p>
        </div>
    </div>
</body>
</html>";
        }
    }
}
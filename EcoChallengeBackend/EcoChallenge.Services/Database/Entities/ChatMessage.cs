using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class ChatMessage
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(Event)), Column("event_id")] 
        public int EventId { get; set; }
        public virtual Event? Event { get; set; }

        [ForeignKey(nameof(Sender)), Column("sender_user_id")]
        public int SenderUserId { get; set; }
        public virtual User? Sender { get; set; }

        [Required, Column("message_text")]
        public string? MessageText { get; set; }
        [Column("message_type")]
        public MessageType MessageType { get; set; } = MessageType.Text;
        [Column("image_url"), MaxLength(255)]
        public string? ImageUrl { get; set; }
        [Column("is_admin_message")]
        public bool IsAdminMessage { get; set; } = false;
        [Column("is_reported")]
        public bool IsReported { get; set; } = false;

        [ForeignKey(nameof(ReportedBy)), Column("reported_by_user_id")]
        public int? ReportedByUserId { get; set; }
        public virtual User? ReportedBy { get; set; }

        [Column("report_reason")] public string? ReportReason { get; set; }
        [Column("is_deleted")] public bool IsDeleted { get; set; } = false;
        [Column("sent_at")] public DateTime SentAt { get; set; } = DateTime.UtcNow;
    }
}

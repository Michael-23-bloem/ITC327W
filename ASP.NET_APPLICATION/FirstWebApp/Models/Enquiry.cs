using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of the enquiries table
    [Table("enquiries")]
    public class Enquiry : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("customer_id")]
        public Guid CustomerId { get; set; }

        [Column("order_id")]
        public Guid? OrderId { get; set; }

        [Column("message")]
        public string Message { get; set; } = string.Empty;

        [Column("status")]
        public string Status { get; set; } = string.Empty;

        // Filled in by the owner in Flutter
        [Column("response", ignoreOnInsert: true)]
        public string? Response { get; set; }

        [Column("responded_by", ignoreOnInsert: true)]
        public Guid? RespondedBy { get; set; }

        [Column("responded_at", ignoreOnInsert: true)]
        public DateTime? RespondedAt { get; set; }

        // Set by Supabase
        [Column("created_at", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public DateTime CreatedAt { get; set; }
    }
}
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // A deposit the owner records against a quotation
    [Table("deposits")]
    public class Deposit : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("quotation_id")]
        public Guid QuotationId { get; set; }

        [Column("amount")]
        public decimal Amount { get; set; }

        [Column("reference")]
        public string? Reference { get; set; }

        [Column("status")]
        public string Status { get; set; } = string.Empty;

        [Column("received_at")]
        public DateTime? ReceivedAt { get; set; }

        [Column("created_at", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public DateTime CreatedAt { get; set; }
    }
}
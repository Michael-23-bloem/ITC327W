using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of quotations. Version 1 is the customer's estimate; the owner adds revised versions.
    [Table("quotations")]
    public class Quotation : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("order_id")]
        public Guid OrderId { get; set; }

        [Column("version")]
        public int Version { get; set; }

        [Column("status")]
        public string Status { get; set; } = string.Empty;

        [Column("estimated_total")]
        public decimal? EstimatedTotal { get; set; }

        // Filled in by the owner in Flutter
        [Column("transportation_fee", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public decimal TransportationFee { get; set; }

        [Column("service_fee", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public decimal ServiceFee { get; set; }

        [Column("final_total", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public decimal? FinalTotal { get; set; }

        [Column("banking_details", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public string? BankingDetails { get; set; }

        [Column("note_to_client", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public string? NoteToClient { get; set; }

        [Column("decline_reason", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public string? DeclineReason { get; set; }

        [Column("created_at", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public DateTime CreatedAt { get; set; }
    }
}
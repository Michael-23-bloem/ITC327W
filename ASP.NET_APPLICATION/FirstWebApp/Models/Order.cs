using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of orders: a customer's quotation request
    [Table("orders")]
    public class Order : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("customer_id")]
        public Guid CustomerId { get; set; }

        [Column("event_type")]
        public string? EventType { get; set; }

        [Column("event_date")]
        public DateTime EventDate { get; set; }

        [Column("venue")]
        public string? Venue { get; set; }

        [Column("guests")]
        public int? Guests { get; set; }

        [Column("notes")]
        public string? Notes { get; set; }

        [Column("status")]
        public string Status { get; set; } = string.Empty;

        // Set by the database / the owner
        [Column("decision_due_at", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public DateTime? DecisionDueAt { get; set; }

        [Column("created_at", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public DateTime CreatedAt { get; set; }
    }
}
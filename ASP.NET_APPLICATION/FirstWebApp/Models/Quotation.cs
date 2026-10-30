using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of quotations: version 1 is the initial quotation the owner reviews
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

        // // A copy of the items at the time of the request
        // [Column("items_snapshot")]
        // public List<QuoteSnapshotLine>? ItemsSnapshot { get; set; }

        [Column("created_at", ignoreOnInsert: true, ignoreOnUpdate: true)]
        public DateTime CreatedAt { get; set; }
    }

    // public class QuoteSnapshotLine
    // {
    //     [JsonPropertyName("type")] public string Type { get; set; } = string.Empty;
    //     [JsonPropertyName("item_id")] public Guid ItemId { get; set; }
    //     [JsonPropertyName("name")] public string Name { get; set; } = string.Empty;
    //     [JsonPropertyName("quantity")] public int Quantity { get; set; }
    //     [JsonPropertyName("unit_price")] public decimal UnitPrice { get; set; }
    //     [JsonPropertyName("line_total")] public decimal LineTotal { get; set; }
    // }
}
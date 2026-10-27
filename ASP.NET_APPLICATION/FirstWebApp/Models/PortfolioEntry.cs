using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of the portfolio table: a previous event
    [Table("portfolio")]
    public class PortfolioEntry : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("name")]
        public string? Name { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("category")]
        public string? Category { get; set; }

        [Column("image_url")]
        public string ImageUrl { get; set; } = string.Empty;

        [Column("price")]
        public decimal? Price { get; set; }   // what the event cost

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }
    }
}
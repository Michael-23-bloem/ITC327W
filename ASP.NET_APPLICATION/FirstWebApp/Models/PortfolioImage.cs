using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // Extra photos for a portfolio event
    [Table("portfolio_images")]
    public class PortfolioImage : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("portfolio_id")]
        public Guid PortfolioId { get; set; }

        [Column("image_url")]
        public string ImageUrl { get; set; } = string.Empty;

        [Column("sort_order")]
        public int SortOrder { get; set; }
    }
}
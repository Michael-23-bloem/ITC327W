using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of portfolio_product_links: a décor product used at a portfolio event
    // (saved by the owner in the Flutter app)
    [Table("portfolio_product_links")]
    public class PortfolioProductLink : BaseModel
    {
        [PrimaryKey("portfolio_id", true)]
        public Guid PortfolioId { get; set; }

        [PrimaryKey("product_id", true)]
        public Guid ProductId { get; set; }
    }
}
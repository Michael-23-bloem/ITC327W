using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One line of a request: either a product or a package
    [Table("order_items")]
    public class OrderItem : BaseModel
    {
        [PrimaryKey("id", false)]
        public Guid Id { get; set; }

        [Column("order_id")]
        public Guid OrderId { get; set; }

        [Column("product_id")]
        public Guid? ProductId { get; set; }

        [Column("package_id")]
        public Guid? PackageId { get; set; }

        [Column("quantity")]
        public int Quantity { get; set; }

        // Set by the database (trg_order_item_price) from the current price
        [Column("unit_price", ignoreOnInsert: true)]
        public decimal UnitPrice { get; set; }
    }
}
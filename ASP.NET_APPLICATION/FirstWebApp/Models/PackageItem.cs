using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace FirstWebApp.Models
{
    // One row of package_items: which product, and how many, a package contains
    [Table("package_items")]
    public class PackageItem : BaseModel
    {
        [PrimaryKey("package_id", true)]
        public Guid PackageId { get; set; }

        [PrimaryKey("product_id", true)]
        public Guid ProductId { get; set; }

        [Column("quantity")]
        public int Quantity { get; set; }
    }
}
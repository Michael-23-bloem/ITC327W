namespace client_decor_app.Models
{
    public enum CatalogueItemType
    {
        Product,
        Package
    }
    public class CatalogueItem
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
        public int StockQuantity { get; set; }
        public CatalogueItemType Type { get; set; }
    }
}
namespace FirstWebApp.Models
{
    // One line in a visitors estimate. Kept in the session, not in Supabase.
    public class EstimateLine
    {
        public Guid ItemId { get; set; }
        public string ItemType { get; set; } = string.Empty;   // "Product" or "Package"
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }

        public decimal LineTotal => Price * Quantity;
    }
}
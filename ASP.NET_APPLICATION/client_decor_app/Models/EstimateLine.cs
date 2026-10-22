namespace client_decor_app.Models
{
    public class EstimateLine
    {
        public int ItemId { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public decimal LineTotal => Price * Quantity;
        public bool NotAvailable { get; set; }
    }
}
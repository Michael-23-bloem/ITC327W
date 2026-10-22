namespace client_decor_app.Models
{
    public class PortfolioItem
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public decimal EventCost { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class PortfolioViewModel
    {
        public string? Category { get; set; }
        public List<string> Categories { get; set; } = new();
        public List<PortfolioItem> Items { get; set; } = new();
    }
}
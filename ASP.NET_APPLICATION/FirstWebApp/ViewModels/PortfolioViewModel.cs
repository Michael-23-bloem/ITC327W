namespace FirstWebApp.ViewModels
{
    // What one portfolio card needs
    public class PortfolioCardViewModel
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? Category { get; set; }
        public decimal? Price { get; set; }
        public string? ImageUrl { get; set; }
    }

        // One product shown in "Items used at this event"
    public class PortfolioUsedItemViewModel
    {
        public string Name { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public decimal Price { get; set; }
    }

    public class PortfolioListViewModel
    {
        public string? Category { get; set; }
        public List<string> Categories { get; set; } = new();
        public List<PortfolioCardViewModel> Items { get; set; } = new();
        public string? Error { get; set; }
    }

    public class PortfolioDetailsViewModel
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? Category { get; set; }
        public decimal? Price { get; set; }
        public List<string> Images { get; set; } = new();  
        public List<PortfolioUsedItemViewModel> ItemsUsed { get; set; } = new();                  // main photo first
        public List<PortfolioCardViewModel> Related { get; set; } = new();   // more from the same category
    }
}
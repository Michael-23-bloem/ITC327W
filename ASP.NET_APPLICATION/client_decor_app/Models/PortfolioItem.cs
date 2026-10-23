namespace client_decor_app.Models
{
    public class PortfolioItem
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;

        // Total the client paid (items + setup, transport, flowers, etc.)
        public decimal EventCost { get; set; }
        public string? ImageUrl { get; set; }   // cover photo

        // Event details shown on the details page
        public string Venue { get; set; } = string.Empty;
        public DateTime EventDate { get; set; }
        public int GuestCount { get; set; }
        public string ColourTheme { get; set; } = string.Empty;

        public List<PortfolioItemUsed> ItemsUsed { get; set; } = new();
        public List<PortfolioImage> Images { get; set; } = new();
    }

    // One catalogue item used at a past event, with the price charged at the time
    public class PortfolioItemUsed
    {
        public int Id { get; set; }
        public int PortfolioItemId { get; set; }
        public int CatalogueItemId { get; set; }
        public CatalogueItem? CatalogueItem { get; set; }
        public int Quantity { get; set; }
        public decimal PriceAtEvent { get; set; }

        // true = goes up/down with the number of guests (chairs, plates, linen)
        // false = fixed amount (backdrop, welcome sign, cake stand)
        public bool ScalesWithGuests { get; set; }

        // How many the customer would need for their own guest count
        public int QuantityFor(int guests, int eventGuests)
        {
            if (!ScalesWithGuests || eventGuests <= 0) return Quantity;
            return Math.Max(1, (int)Math.Ceiling(Quantity * (double)guests / eventGuests));
        }
    }

    // Extra photos for the gallery thumbnails
    public class PortfolioImage
    {
        public int Id { get; set; }
        public int PortfolioItemId { get; set; }
        public string Url { get; set; } = string.Empty;
        public int SortOrder { get; set; }
    }

    public class PortfolioViewModel
    {
        public string? Category { get; set; }
        public List<string> Categories { get; set; } = new();
        public List<PortfolioItem> Items { get; set; } = new();
    }

    // ---------- Details page ----------

    public class PortfolioLine
    {
        public CatalogueItem CatalogueItem { get; set; } = null!;
        public int QuantityAtEvent { get; set; }
        public decimal PriceAtEvent { get; set; }
        public bool ScalesWithGuests { get; set; }
        public int YourQuantity { get; set; }

        public decimal TotalAtEvent => QuantityAtEvent * PriceAtEvent;
        public decimal YourTotal => YourQuantity * CatalogueItem.Price;   // today's price
    }

    public class PortfolioDetailsViewModel
    {
        public PortfolioItem Item { get; set; } = null!;
        public List<PortfolioLine> Lines { get; set; } = new();
        public int Guests { get; set; }
        public DateTime? EventDate { get; set; }

        public decimal ItemsSubtotal => Lines.Sum(l => l.TotalAtEvent);
        public decimal OtherCosts => Math.Max(0, Item.EventCost - ItemsSubtotal);
        public decimal YourItemsTotal => Lines.Sum(l => l.YourTotal);
    }
}
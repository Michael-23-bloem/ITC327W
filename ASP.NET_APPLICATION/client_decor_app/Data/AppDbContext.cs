using client_decor_app.Models;
using Microsoft.EntityFrameworkCore;

namespace client_decor_app.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<CatalogueItem> CatalogueItems { get; set; }
        public DbSet<PortfolioItem> PortfolioItems { get; set; }
        public DbSet<Reservation> Reservations { get; set; }
        public DbSet<PortfolioItemUsed> PortfolioItemsUsed { get; set; }
        public DbSet<PortfolioImage> PortfolioImages { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<CatalogueItem>()
                .Property(i => i.Price)
                .HasPrecision(10, 2);

            // Sample data 
            builder.Entity<CatalogueItem>().HasData(
                new CatalogueItem { Id = 1, Name = "Gold chiavari chair", Description = "Classic event seating", Price = 45, StockQuantity = 100, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 2, Name = "Round table linen", Description = "White, fits 1.8 m tables", Price = 60, StockQuantity = 40, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 3, Name = "Floral centrepiece", Description = "Fresh seasonal flowers", Price = 250, StockQuantity = 10, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 4, Name = "Fairy light backdrop", Description = "3 m x 3 m warm white", Price = 800, StockQuantity = 2, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 5, Name = "Cake stand", Description = "Gold mirror finish", Price = 120, StockQuantity = 6, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 6, Name = "Welcome sign", Description = "Custom wording on easel", Price = 350, StockQuantity = 4, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 7, Name = "Candle holder set", Description = "Set of 3 glass holders", Price = 75, StockQuantity = 30, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 8, Name = "Charger plate", Description = "Gold rim", Price = 25, StockQuantity = 150, Type = CatalogueItemType.Product },
                new CatalogueItem { Id = 101, Name = "Birthday package", Description = "Decor for up to 30 guests", Price = 4500, StockQuantity = 3, Type = CatalogueItemType.Package },
                new CatalogueItem { Id = 102, Name = "Baby shower package", Description = "Backdrop, table and balloons", Price = 3800, StockQuantity = 2, Type = CatalogueItemType.Package },
                new CatalogueItem { Id = 103, Name = "Wedding package", Description = "Full venue styling for 100 guests", Price = 18000, StockQuantity = 1, Type = CatalogueItemType.Package },
                new CatalogueItem { Id = 104, Name = "Year-end function package", Description = "Corporate decor for 50 guests", Price = 9500, StockQuantity = 2, Type = CatalogueItemType.Package }
            );

            // Sample bookings so you can test the different messages
            builder.Entity<Reservation>().HasData(
               new Reservation { Id = 1, CatalogueItemId = 3, EventDate = new DateTime(2027, 1, 14), Quantity = 9 },   // 1 centrepiece left
               new Reservation { Id = 2, CatalogueItemId = 1, EventDate = new DateTime(2027, 1, 14), Quantity = 80 },  // 20 chairs left
               new Reservation { Id = 3, CatalogueItemId = 4, EventDate = new DateTime(2026, 12, 12), Quantity = 2 },  // backdrop fully booked
               new Reservation { Id = 4, CatalogueItemId = 103, EventDate = new DateTime(2026, 12, 12), Quantity = 1 } // wedding package booked
            );
            
                        // ---------- Portfolio ----------
            builder.Entity<PortfolioItem>()
                .Property(p => p.EventCost)
                .HasPrecision(10, 2);

            builder.Entity<PortfolioItemUsed>()
                .Property(u => u.PriceAtEvent)
                .HasPrecision(10, 2);

            builder.Entity<PortfolioItem>().HasData(
                new PortfolioItem { Id = 1, Title = "Garden wedding", Description = "White and gold styling for 120 guests", Category = "Weddings", EventCost = 25000,
                    Venue = "Garden venue, Johannesburg", EventDate = new DateTime(2026, 3, 14), GuestCount = 120, ColourTheme = "White & gold" },
                new PortfolioItem { Id = 2, Title = "Winter wedding", Description = "Candlelit hall with deep red florals", Category = "Weddings", EventCost = 32000,
                    Venue = "Function hall, Sandton", EventDate = new DateTime(2026, 7, 11), GuestCount = 150, ColourTheme = "Deep red & candlelight" },
                new PortfolioItem { Id = 3, Title = "21st birthday", Description = "Black and gold balloon wall and lounge", Category = "Birthdays", EventCost = 6500,
                    Venue = "Private home, Soweto", EventDate = new DateTime(2026, 5, 23), GuestCount = 60, ColourTheme = "Black & gold" },
                new PortfolioItem { Id = 4, Title = "40th birthday dinner", Description = "Long table setting with fresh flowers", Category = "Birthdays", EventCost = 8000,
                    Venue = "Restaurant, Rosebank", EventDate = new DateTime(2026, 8, 15), GuestCount = 40, ColourTheme = "Greenery & blush" },
                new PortfolioItem { Id = 5, Title = "Year-end function", Description = "Corporate decor for 80 staff", Category = "Corporate", EventCost = 15000,
                    Venue = "Office, Midrand", EventDate = new DateTime(2025, 12, 5), GuestCount = 80, ColourTheme = "Navy & silver" },
                new PortfolioItem { Id = 6, Title = "Product launch", Description = "Branded backdrop and cocktail tables", Category = "Corporate", EventCost = 12000,
                    Venue = "Showroom, Fourways", EventDate = new DateTime(2026, 4, 9), GuestCount = 100, ColourTheme = "Brand colours" },
                new PortfolioItem { Id = 7, Title = "Pastel baby shower", Description = "Balloon arch and dessert table", Category = "Baby Showers", EventCost = 4500,
                    Venue = "Private home, Randburg", EventDate = new DateTime(2026, 6, 20), GuestCount = 30, ColourTheme = "Pastel pink & blue" },
                new PortfolioItem { Id = 8, Title = "Safari kids party", Description = "Jungle theme for 25 children", Category = "Kids Party", EventCost = 5000,
                    Venue = "Community hall, Roodepoort", EventDate = new DateTime(2026, 2, 28), GuestCount = 25, ColourTheme = "Jungle green" }
            );

            // Items used at each event: (id, event, catalogue item, qty, price then, scales with guests?)
            static PortfolioItemUsed U(int id, int portfolio, int item, int qty, decimal price, bool scales) =>
                new() { Id = id, PortfolioItemId = portfolio, CatalogueItemId = item, Quantity = qty, PriceAtEvent = price, ScalesWithGuests = scales };

            builder.Entity<PortfolioItemUsed>().HasData(
                // 1 Garden wedding (120 guests)
                U(1, 1, 1, 120, 40, true), U(2, 1, 2, 12, 55, true), U(3, 1, 3, 12, 220, true),
                U(4, 1, 4, 1, 750, false), U(5, 1, 5, 1, 110, false), U(6, 1, 6, 1, 350, false), U(7, 1, 8, 120, 25, true),
                // 2 Winter wedding (150 guests)
                U(8, 2, 1, 150, 40, true), U(9, 2, 2, 15, 55, true), U(10, 2, 3, 15, 240, true),
                U(11, 2, 7, 45, 70, true), U(12, 2, 8, 150, 25, true), U(13, 2, 6, 1, 350, false),
                // 3 21st birthday (60 guests)
                U(14, 3, 1, 60, 42, true), U(15, 3, 4, 1, 780, false), U(16, 3, 5, 1, 120, false), U(17, 3, 6, 1, 350, false),
                // 4 40th birthday dinner (40 guests)
                U(18, 4, 1, 40, 45, true), U(19, 4, 2, 4, 60, true), U(20, 4, 3, 4, 250, true),
                U(21, 4, 7, 12, 75, true), U(22, 4, 8, 40, 25, true),
                // 5 Year-end function (80 guests)
                U(23, 5, 1, 80, 45, true), U(24, 5, 2, 8, 60, true), U(25, 5, 3, 8, 250, true), U(26, 5, 4, 1, 800, false),
                // 6 Product launch (100 guests)
                U(27, 6, 4, 2, 800, false), U(28, 6, 7, 10, 75, true), U(29, 6, 6, 2, 350, false),
                // 7 Pastel baby shower (30 guests)
                U(30, 7, 1, 30, 45, true), U(31, 7, 5, 2, 120, false), U(32, 7, 4, 1, 800, false), U(33, 7, 6, 1, 350, false),
                // 8 Safari kids party (25 guests)
                U(34, 8, 1, 25, 45, true), U(35, 8, 2, 3, 60, true), U(36, 8, 5, 1, 120, false)
            );
        }
    }
}

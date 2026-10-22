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
            
            builder.Entity<PortfolioItem>()
            .Property(p => p.EventCost)
            .HasPrecision(10, 2);

            // Sample data
            builder.Entity<PortfolioItem>().HasData(
                new PortfolioItem { Id = 1, Title = "Garden wedding", Description = "White and gold styling for 120 guests", Category = "Weddings", EventCost = 25000 },
                new PortfolioItem { Id = 2, Title = "Winter wedding", Description = "Candlelit hall with deep red florals", Category = "Weddings", EventCost = 32000 },
                new PortfolioItem { Id = 3, Title = "21st birthday", Description = "Black and gold balloon wall and lounge", Category = "Birthdays", EventCost = 6500 },
                new PortfolioItem { Id = 4, Title = "40th birthday dinner", Description = "Long table setting with fresh flowers", Category = "Birthdays", EventCost = 8000 },
                new PortfolioItem { Id = 5, Title = "Year-end function", Description = "Corporate decor for 80 staff", Category = "Corporate", EventCost = 15000 },
                new PortfolioItem { Id = 6, Title = "Product launch", Description = "Branded backdrop and cocktail tables", Category = "Corporate", EventCost = 12000 },
                new PortfolioItem { Id = 7, Title = "Pastel baby shower", Description = "Balloon arch and dessert table", Category = "Baby Showers", EventCost = 4500 },
                new PortfolioItem { Id = 8, Title = "Safari kids party", Description = "Jungle theme for 25 children", Category = "Kids Party", EventCost = 5000 }
            );
        }
    }
}

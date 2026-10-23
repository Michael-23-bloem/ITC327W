using client_decor_app.Data;
using client_decor_app.Models;
using client_decor_app.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace client_decor_app.Controllers
{
    public class PortfolioController : Controller
    {
        // The filter buttons
        private static readonly List<string> Categories = new()
        {
            "Weddings", "Birthdays", "Corporate", "Baby Showers", "Kids Party"
        };

        private readonly AppDbContext _db;
        private readonly EstimateService _estimate;

        public PortfolioController(AppDbContext db, EstimateService estimate)
        {
            _db = db;
            _estimate = estimate;
        }

        // /Portfolio or /Portfolio?category=Weddings
        public async Task<IActionResult> Index(string? category)
        {
            var query = _db.PortfolioItems.AsQueryable();

            if (!string.IsNullOrEmpty(category))
            {
                query = query.Where(p => p.Category == category);
            }

            var model = new PortfolioViewModel
            {
                Category = category,
                Categories = Categories,
                Items = await query.OrderBy(p => p.Title).ToListAsync()
            };

            return View(model);
        }

        // /Portfolio/Details/3  or  /Portfolio/Details/3?guests=80
        public async Task<IActionResult> Details(int id, int? guests)
        {
            var item = await _db.PortfolioItems
                .Include(p => p.ItemsUsed).ThenInclude(u => u.CatalogueItem)
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (item == null) return NotFound();

            // Default to the original event's guest count
            var plannedGuests = Math.Clamp(guests ?? item.GuestCount, 1, 1000);

            var model = new PortfolioDetailsViewModel
            {
                Item = item,
                Guests = plannedGuests,
                EventDate = _estimate.EventDate,
                Lines = item.ItemsUsed
                    .Where(u => u.CatalogueItem != null)
                    .OrderBy(u => u.Id)
                    .Select(u => new PortfolioLine
                    {
                        CatalogueItem = u.CatalogueItem!,
                        QuantityAtEvent = u.Quantity,
                        PriceAtEvent = u.PriceAtEvent,
                        ScalesWithGuests = u.ScalesWithGuests,
                        YourQuantity = u.QuantityFor(plannedGuests, item.GuestCount)
                    })
                    .ToList()
            };

            return View(model);
        }
    }
}
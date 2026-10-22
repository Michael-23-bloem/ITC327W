using client_decor_app.Data;
using client_decor_app.Models;
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

        public PortfolioController(AppDbContext db)
        {
            _db = db;
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

        // /Portfolio/Details/3
        public async Task<IActionResult> Details(int id)
        {
            var item = await _db.PortfolioItems.FindAsync(id);
            if (item == null) return NotFound();

            return View(item);
        }
    }
}
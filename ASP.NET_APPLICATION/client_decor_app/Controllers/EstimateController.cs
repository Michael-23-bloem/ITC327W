using client_decor_app.Data;
using client_decor_app.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace client_decor_app.Controllers
{
    public class EstimateController : Controller
    {
        private readonly AppDbContext _db;
        private readonly EstimateService _estimate;
        private readonly AvailabilityService _availability;

        public EstimateController(AppDbContext db, EstimateService estimate, AvailabilityService availability)
        {
            _db = db;
            _estimate = estimate;
            _availability = availability;
        }

        // Full "View estimate" page
        public IActionResult Index()
        {
            return View(_estimate.GetLines());
        }

        // Called by the dialog: /Estimate/Availability?itemId=3&date=2027-01-14
        [HttpGet]
        public async Task<IActionResult> Availability(int itemId, DateTime date)
        {
            if (date.Date <= DateTime.Today) return BadRequest();

            var available = await _availability.GetAvailableAsync(itemId, date);
            return Json(new { available });
        }

        // choice = "available" (add what's free) or "requested" (add the full amount)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Add(int itemId, int quantity, DateTime eventDate, string choice, string? returnUrl)
        {
            var back = returnUrl ?? Url.Action("Products", "Catalogue")!;

            var item = await _db.CatalogueItems.FindAsync(itemId);
            if (item == null) return NotFound();

            if (eventDate.Date <= DateTime.Today)
            {
                TempData["Added"] = "Choose an event date after today.";
                return LocalRedirect(back);
            }

            if (quantity < 1) quantity = 1;

            var available = await _availability.GetAvailableAsync(itemId, eventDate);
            var notAvailable = false;

            if (choice == "available")
            {
                quantity = Math.Min(quantity, available);
            }
            else
            {
                notAvailable = quantity > available;
            }

            if (quantity < 1)
            {
                TempData["Added"] = $"No {item.Name} available on {eventDate:d MMM yyyy}. Try a different date.";
                return LocalRedirect(back);
            }

            _estimate.EventDate = eventDate.Date;
            _estimate.Add(item, quantity, notAvailable);

            TempData["Added"] = notAvailable
                ? $"{quantity} x {item.Name} added. Not all are free on {eventDate:d MMM yyyy}, so we'll confirm in your quote."
                : $"{quantity} x {item.Name} added to your estimate.";

            return LocalRedirect(back);
        }

        // "Add all items to my estimate" on the portfolio details page
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddPortfolio(int portfolioId, int guests, DateTime eventDate)
        {
            guests = Math.Clamp(guests, 1, 1000);
            var back = Url.Action("Details", "Portfolio", new { id = portfolioId, guests })!;

            var portfolio = await _db.PortfolioItems
                .Include(p => p.ItemsUsed).ThenInclude(u => u.CatalogueItem)
                .FirstOrDefaultAsync(p => p.Id == portfolioId);

            if (portfolio == null) return NotFound();

            if (eventDate.Date <= DateTime.Today)
            {
                TempData["Added"] = "Choose an event date after today.";
                return LocalRedirect(back);
            }

            var added = 0;
            var notFullyAvailable = 0;

            foreach (var used in portfolio.ItemsUsed.Where(u => u.CatalogueItem != null))
            {
                var quantity = used.QuantityFor(guests, portfolio.GuestCount);
                var available = await _availability.GetAvailableAsync(used.CatalogueItemId, eventDate);
                var notAvailable = quantity > available;

                _estimate.Add(used.CatalogueItem!, quantity, notAvailable);

                added++;
                if (notAvailable) notFullyAvailable++;
            }

            _estimate.EventDate = eventDate.Date;

            TempData["Added"] = notFullyAvailable == 0
                ? $"{added} items from “{portfolio.Title}” added to your estimate for {guests} guests."
                : $"{added} items added for {guests} guests. {notFullyAvailable} aren't fully free on {eventDate:d MMM yyyy}, so we'll confirm them in your quote.";

            return LocalRedirect(back);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Remove(int itemId, string? returnUrl)
        {
            _estimate.Remove(itemId);
            return LocalRedirect(returnUrl ?? Url.Action(nameof(Index))!);
        }
    }
}
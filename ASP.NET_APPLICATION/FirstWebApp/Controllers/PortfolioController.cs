using FirstWebApp.Models;
using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest;
using Supabase.Postgrest.Exceptions;

namespace FirstWebApp.Controllers
{
    public class PortfolioController : Controller
    {
        private const string LoadError = "We couldn't load the portfolio right now. Please try again in a moment.";

        private readonly Supabase.Client _supabase;
        private readonly ILogger<PortfolioController> _logger;

        public PortfolioController(Supabase.Client supabase, ILogger<PortfolioController> logger)
        {
            _supabase = supabase;
            _logger = logger;
        }

        // /Portfolio or /Portfolio?category=Weddings
        public async Task<IActionResult> Index(string? category)
        {
            var model = new PortfolioListViewModel { Category = category };

            try
            {
                var entries = (await _supabase.From<PortfolioEntry>()
                    .Order(p => p.CreatedAt, Constants.Ordering.Descending)
                    .Get()).Models;

                // The filter pills come from the events themselves
                model.Categories = entries
                    .Select(e => e.Category)
                    .Where(c => !string.IsNullOrWhiteSpace(c))
                    .Select(c => c!.Trim())
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .OrderBy(c => c)
                    .ToList();

                model.Items = entries
                    .Where(e => string.IsNullOrEmpty(category)
                             || string.Equals(e.Category?.Trim(), category, StringComparison.OrdinalIgnoreCase))
                    .Select(ToCard)
                    .ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading the portfolio from Supabase failed");
                model.Error = LoadError;
            }

            return View(model);
        }

        // /Portfolio/Details/{id}
        public async Task<IActionResult> Details(Guid id)
        {
            try
            {
                var entry = await _supabase.From<PortfolioEntry>()
                    .Where(p => p.Id == id)
                    .Single();

                if (entry == null) return NotFound();

                var extraPhotos = (await _supabase.From<PortfolioImage>()
                    .Where(i => i.PortfolioId == id)
                    .Order(i => i.SortOrder, Constants.Ordering.Ascending)
                    .Get()).Models;

                // Main photo first, then the extra photos (skipping blanks and duplicates)
                var images = new List<string>();
                foreach (var url in new[] { entry.ImageUrl }.Concat(extraPhotos.Select(i => i.ImageUrl)))
                {
                    if (!string.IsNullOrWhiteSpace(url) && !images.Contains(url)) images.Add(url);
                }

                var related = new List<PortfolioEntry>();
                if (!string.IsNullOrWhiteSpace(entry.Category))
                {
                    related = (await _supabase.From<PortfolioEntry>()
                        .Filter("category", Constants.Operator.Equals, entry.Category)
                        .Filter("id", Constants.Operator.NotEqual, id.ToString())
                        .Limit(3)
                        .Get()).Models;
                }

                var model = new PortfolioDetailsViewModel
                {
                    Id = entry.Id,
                    Title = entry.Name ?? "Untitled event",
                    Description = entry.Description,
                    Category = entry.Category,
                    Price = entry.Price,
                    Images = images,
                    Related = related.Select(ToCard).ToList()
                };

                return View(model);
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading portfolio event {Id} failed", id);
                TempData["PortfolioError"] = LoadError;
                return RedirectToAction(nameof(Index));
            }
        }

        private static PortfolioCardViewModel ToCard(PortfolioEntry e) => new()
        {
            Id = e.Id,
            Title = e.Name ?? "Untitled event",
            Description = e.Description,
            Category = e.Category,
            Price = e.Price,
            ImageUrl = string.IsNullOrWhiteSpace(e.ImageUrl) ? null : e.ImageUrl
        };
    }
}
using System.Diagnostics;
using FirstWebApp.Models;
using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest;
using Supabase.Postgrest.Exceptions;

namespace FirstWebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly Supabase.Client _supabase;
        private readonly ILogger<HomeController> _logger;

        public HomeController(Supabase.Client supabase, ILogger<HomeController> logger)
        {
            _supabase = supabase;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            // Placeholder content, except "Work", which comes from Supabase
            var model = new HomeViewModel
            {
                HeroSlides = new()
                {
                    "images/hero/slides-1.jpg",
                    "images/hero/slides-2.jpg",
                    "images/hero/slides-3.jpg",
                    "images/hero/slides-4.jpg"
                },

                AboutImage = "images/about/team.jpg",

                Occasions = new()
                {
                    new("Weddings",      "images/occasion/weddings.jpg"),
                    new("Birthdays",     "images/occasion/birthdays.jpg"),
                    new("Corporate",     "images/occasion/corporates.jpg"),
                    new("Kid's parties", "images/occasion/kidsparties.jpg"),
                    new("Baby showers",  "images/occasion/babyshowers.jpg")
                },

                Packages = await LoadRecentPackagesAsync(),

                Work = await LoadRecentWorkAsync()
            };

            return View(model);
        }

        public IActionResult Privacy() => View();

        public IActionResult Terms()
        {
            ViewData["Title"] = "Terms and conditions";
            ViewData["Lead"] = "Our terms for quotations, deposits, bookings and cancellations.";
            return View("ComingSoon");
        }

        public IActionResult About() => View();

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error() =>
            View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });

        // The three most recent events from the portfolio table
        private async Task<List<PortfolioCardViewModel>> LoadRecentWorkAsync()
        {
            try
            {
                var entries = (await _supabase.From<PortfolioEntry>()
                    .Order(p => p.CreatedAt, Constants.Ordering.Descending)
                    .Limit(3)
                    .Get()).Models;

                return entries.Select(e => new PortfolioCardViewModel
                {
                    Id = e.Id,
                    Title = e.Name ?? "Untitled event",
                    Description = e.Description,
                    Category = e.Category,
                    Price = e.Price,
                    ImageUrl = string.IsNullOrWhiteSpace(e.ImageUrl) ? null : e.ImageUrl
                }).ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                // The home page should still load if Supabase is unavailable
                _logger.LogWarning(ex, "Loading recent portfolio work for the home page failed");
                return new();
            }
        }
        // The three most recently added packages that are shown on the website
        private async Task<List<HomePackage>> LoadRecentPackagesAsync()
        {
            try
            {
                var packages = (await _supabase.From<DecorPackage>()
                    .Where(p => p.IsActive == true)
                    .Order(p => p.CreatedAt, Constants.Ordering.Descending)
                    .Limit(3)
                    .Get()).Models;

                return packages.Select(p => new HomePackage(
                    p.Name,
                    p.Description ?? string.Empty,
                    "R " + p.Price.ToString("N0"),
                    p.ImageUrl ?? string.Empty)).ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogWarning(ex, "Loading packages for the home page failed");
                return new();
            }
        }
    }
}
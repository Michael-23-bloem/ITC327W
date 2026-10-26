using System.Diagnostics;
using FirstWebApp.Models;
using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Mvc;

namespace FirstWebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            // Placeholder content: packages and work will come from Supabase later
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
                    new("Corporate",     "images/occasion/corporate.jpg"),
                    new("Kid's parties", "images/occasion/kids-parties.jpg"),
                    new("Baby showers",  "images/occasion/baby-showers.jpg")
                },

                Packages = new()
                {
                    new("[Package name]", "[Short package description]", "R0.000", "images/packages/package-1.jpg"),
                    new("[Package name]", "[Short package description]", "R0.000", "images/packages/package-2.jpg"),
                    new("[Package name]", "[Short package description]", "R0.000", "images/packages/package-3.jpg")
                },

                Work = new()
                {
                    new("[Event title]", "Wedding ~ [Venue] ~ [Date]",      "images/work/work-1.jpg"),
                    new("[Event title]", "Birthday ~ [Venue] ~ [Date]",     "images/work/work-2.jpg"),
                    new("[Event title]", "Corporate ~ [Venue] ~ [Date]",    "images/work/work-3.jpg"),
                    new("[Event title]", "Kid's party ~ [Venue] ~ [Date]",  "images/work/work-4.jpg"),
                    new("[Event title]", "Baby shower ~ [Venue] ~ [Date]",  "images/work/work-5.jpg")
                }
            };

            return View(model);
        }

        public IActionResult Privacy() => View();

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error() =>
            View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
using FirstWebApp.Models;
using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest;
using Supabase.Postgrest.Exceptions;

namespace FirstWebApp.Controllers
{
    public class CatalogueController : Controller
    {
        private const string LoadError = "We couldn't load the catalogue right now. Please try again in a moment.";

        private readonly Supabase.Client _supabase;
        private readonly ILogger<CatalogueController> _logger;

        public CatalogueController(Supabase.Client supabase, ILogger<CatalogueController> logger)
        {
            _supabase = supabase;
            _logger = logger;
        }

        // /Catalogue goes straight to the Decor products tab
        public IActionResult Index() => RedirectToAction(nameof(Products));

        // /Catalogue/Products?category=Lighting&search=gold
        public async Task<IActionResult> Products(string? search, string? category)
        {
            var model = new CatalogueViewModel { Tab = "Products", Search = search, Category = category };

            try
            {
                var response = await _supabase.From<DecorProduct>()
                    .Where(p => p.IsActive == true)
                    .Order(p => p.Name, Constants.Ordering.Ascending)
                    .Get();

                var products = response.Models;

                // The category pills come from the products themselves
                model.Categories = products
                    .Select(p => p.Category)
                    .Where(c => !string.IsNullOrWhiteSpace(c))
                    .Select(c => c!.Trim())
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .OrderBy(c => c)
                    .ToList();

                model.Items = products
                    .Where(p => string.IsNullOrEmpty(category)
                             || string.Equals(p.Category?.Trim(), category, StringComparison.OrdinalIgnoreCase))
                    .Where(p => Matches(search, p.Name, p.Description))
                    .Select(p => new CatalogueItemViewModel
                    {
                        Id = p.Id,
                        ItemType = CatalogueItemTypes.Product,
                        Name = p.Name,
                        Description = p.Description,
                        Price = p.Price,
                        ImageUrl = p.ImageUrl,
                        Category = p.Category
                    })
                    .ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading decor products from Supabase failed");
                model.Error = LoadError;
            }

            return View("Catalogue", model);
        }

        // /Catalogue/Packages?search=wedding
        public async Task<IActionResult> Packages(string? search)
        {
            var model = new CatalogueViewModel { Tab = "Packages", Search = search };

            try
            {
                var response = await _supabase.From<DecorPackage>()
                    .Where(p => p.IsActive == true)
                    .Order(p => p.Name, Constants.Ordering.Ascending)
                    .Get();

                model.Items = response.Models
                    .Where(p => Matches(search, p.Name, p.Description))
                    .Select(p => new CatalogueItemViewModel
                    {
                        Id = p.Id,
                        ItemType = CatalogueItemTypes.Package,
                        Name = p.Name,
                        Description = p.Description,
                        Price = p.Price,
                        ImageUrl = p.ImageUrl
                    })
                    .ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading packages from Supabase failed");
                model.Error = LoadError;
            }

            return View("Catalogue", model);
        }

        // True when there's no search, or the text appears in any of the fields (ignoring case)
        private static bool Matches(string? search, params string?[] fields) =>
            string.IsNullOrWhiteSpace(search)
            || fields.Any(f => f != null && f.Contains(search.Trim(), StringComparison.OrdinalIgnoreCase));
    }
}
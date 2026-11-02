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

                var packages = response.Models
                    .Where(p => Matches(search, p.Name, p.Description))
                    .ToList();

                var contents = await LoadPackageContentsAsync(packages.Select(p => p.Id).ToList());

                model.Items = packages
                    .Select(p => new CatalogueItemViewModel
                    {
                        Id = p.Id,
                        ItemType = CatalogueItemTypes.Package,
                        Name = p.Name,
                        Description = p.Description,
                        Price = p.Price,
                        ImageUrl = p.ImageUrl,
                        Contents = contents.TryGetValue(p.Id, out var items) ? items : new()
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

        // /Catalogue/Availability?itemId=…&itemType=…&date=2026-12-12&quantity=40
        [HttpGet]
        public async Task<IActionResult> Availability(Guid itemId, string itemType, DateTime? date, int quantity = 1)
        {
            var earliest = DateTime.Today.AddDays(QuoteRequestViewModel.MinDaysAhead);

            if (date == null)
                return Json(new AvailabilityResult("error", "Please choose your event date."));

            var day = date.Value.Date;

            if (day < earliest)
                return Json(new AvailabilityResult("error", $"Please choose a date from {earliest:d MMMM yyyy}."));

            if (day > DateTime.Today.AddYears(2))
                return Json(new AvailabilityResult("error", "Please choose a date within the next two years."));

            try
            {
                var result = itemType == CatalogueItemTypes.Package
                    ? await CheckPackageAsync(itemId, day)
                    : await CheckProductAsync(itemId, day, Math.Clamp(quantity, 1, 999));

                return Json(result);
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Checking availability for {ItemId} failed", itemId);
                return Json(new AvailabilityResult("error", "We couldn't check availability right now. Please try again."));
            }
        }

        // How many of a product are free on a date (worked out by the database)
        private async Task<int> AvailableQuantityAsync(Guid productId, DateTime day)
        {
            var response = await _supabase.Rpc("product_available_quantity", new Dictionary<string, object>
            {
                ["p_product"] = productId.ToString(),
                ["p_date"] = day.ToString("yyyy-MM-dd")
            });

            return int.TryParse(response.Content, out var free) ? free : 0;
        }

        private async Task<AvailabilityResult> CheckProductAsync(Guid productId, DateTime day, int wanted)
        {
            var dateText = day.ToString("ddd d MMM yyyy");
            var free = await AvailableQuantityAsync(productId, day);

            if (free == 0)
                return new AvailabilityResult("unavailable", $"Not available on {dateText}.");

            if (free < wanted)
                return new AvailabilityResult("low", $"Only {free} available on {dateText} (you chose {wanted}).");

            return new AvailabilityResult("available", $"Available on {dateText}: {free} free.");
        }

        private async Task<AvailabilityResult> CheckPackageAsync(Guid packageId, DateTime day)
        {
            var dateText = day.ToString("ddd d MMM yyyy");

            var links = (await _supabase.From<PackageItem>()
                .Where(pi => pi.PackageId == packageId)
                .Get()).Models;

            if (links.Count == 0)
                return new AvailabilityResult("unavailable", "This package has no items yet.");

            var productIds = links.Select(l => l.ProductId.ToString()).Distinct().ToList();
            var names = (await _supabase.From<DecorProduct>()
                .Filter("id", Constants.Operator.In, productIds)
                .Get()).Models.ToDictionary(p => p.Id, p => p.Name);

            // Check every item in the package at the same time
            var checks = await Task.WhenAll(links.Select(async l =>
                (Link: l, Free: await AvailableQuantityAsync(l.ProductId, day))));

            var short_ = checks.Where(c => c.Free < c.Link.Quantity).ToList();

            if (short_.Count == 0)
                return new AvailabilityResult("available", $"Available on {dateText}.");

            var details = string.Join("; ", short_.Take(2).Select(c =>
            {
                var name = names.TryGetValue(c.Link.ProductId, out var n) ? n : "an item";
                return $"only {c.Free} of the {c.Link.Quantity} {name} are free";
            }));

            return new AvailabilityResult("unavailable", $"Not available on {dateText}: {details}.");
        }

        // Which products (and how many) each package contains, keyed by package id
        private async Task<Dictionary<Guid, List<PackageContentViewModel>>> LoadPackageContentsAsync(List<Guid> packageIds)
        {
            var result = new Dictionary<Guid, List<PackageContentViewModel>>();
            if (packageIds.Count == 0) return result;

            var links = (await _supabase.From<PackageItem>()
                .Filter("package_id", Constants.Operator.In, packageIds.Select(id => id.ToString()).ToList())
                .Get()).Models;

            if (links.Count == 0) return result;

            var productIds = links.Select(l => l.ProductId.ToString()).Distinct().ToList();

            var products = (await _supabase.From<DecorProduct>()
                .Filter("id", Constants.Operator.In, productIds)
                .Get()).Models
                .ToDictionary(p => p.Id);

            foreach (var link in links)
            {
                // Skip products that are hidden or no longer exist
                if (!products.TryGetValue(link.ProductId, out var product)) continue;

                if (!result.TryGetValue(link.PackageId, out var list))
                {
                    result[link.PackageId] = list = new();
                }

                list.Add(new PackageContentViewModel
                {
                    Name = product.Name,
                    Description = product.Description,
                    ImageUrl = product.ImageUrl,
                    Quantity = link.Quantity
                });
            }

            foreach (var list in result.Values)
            {
                list.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase));
            }

            return result;
        }

        // True when there's no search, or the text appears in any of the fields (ignoring case)
        private static bool Matches(string? search, params string?[] fields) =>
            string.IsNullOrWhiteSpace(search)
            || fields.Any(f => f != null && f.Contains(search.Trim(), StringComparison.OrdinalIgnoreCase));
    }
}
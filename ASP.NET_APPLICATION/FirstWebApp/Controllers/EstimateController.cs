using FirstWebApp.Models;
using FirstWebApp.Services;
using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest.Exceptions;

namespace FirstWebApp.Controllers
{
    public class EstimateController : Controller
    {
        private readonly Supabase.Client _supabase;
        private readonly EstimateService _estimate;
        private readonly ILogger<EstimateController> _logger;

        public EstimateController(Supabase.Client supabase, EstimateService estimate, ILogger<EstimateController> logger)
        {
            _supabase = supabase;
            _estimate = estimate;
            _logger = logger;
        }

        // The full "Your estimate" page
        public IActionResult Index() => View(_estimate.GetLines());

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Add(Guid itemId, string itemType, int quantity, string? returnUrl)
        {
            var back = Url.IsLocalUrl(returnUrl) ? returnUrl! : Url.Action("Products", "Catalogue")!;
            quantity = Math.Clamp(quantity, 1, 999);

            if (itemType != CatalogueItemTypes.Product && itemType != CatalogueItemTypes.Package)
            {
                return BadRequest();
            }

            try
            {
                // Name and price always come from Supabase, never from the form
                var item = itemType == CatalogueItemTypes.Package
                    ? await FindPackageAsync(itemId)
                    : await FindProductAsync(itemId);

                if (item == null)
                {
                    TempData["Added"] = "That item is no longer available.";
                    return LocalRedirect(back);
                }

                _estimate.Add(itemId, itemType, item.Value.Name, item.Value.Price, quantity);
                TempData["Added"] = $"{quantity} x {item.Value.Name} added to your estimate.";
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Adding {ItemType} {ItemId} to the estimate failed", itemType, itemId);
                TempData["Added"] = "We couldn't add that item right now. Please try again.";
            }

            return LocalRedirect(back);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Remove(Guid itemId, string itemType, string? returnUrl)
        {
            _estimate.Remove(itemId, itemType);
            return LocalRedirect(Url.IsLocalUrl(returnUrl) ? returnUrl! : Url.Action(nameof(Index))!);
        }

        private async Task<(string Name, decimal Price)?> FindProductAsync(Guid id)
        {
            var product = await _supabase.From<DecorProduct>()
                .Where(p => p.Id == id)
                .Where(p => p.IsActive == true)
                .Single();

            return product == null ? null : (product.Name, product.Price);
        }

        private async Task<(string Name, decimal Price)?> FindPackageAsync(Guid id)
        {
            var package = await _supabase.From<DecorPackage>()
                .Where(p => p.Id == id)
                .Where(p => p.IsActive == true)
                .Single();

            return package == null ? null : (package.Name, package.Price);
        }
    }
}
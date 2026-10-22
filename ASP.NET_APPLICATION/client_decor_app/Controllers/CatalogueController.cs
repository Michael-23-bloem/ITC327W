using client_decor_app.Data;
using client_decor_app.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace client_decor_app.Controllers
{
    public class CatalogueController : Controller
    {
        private readonly AppDbContext _db;

        public CatalogueController(AppDbContext db)
        {
            _db = db;
        }

        // /Catalogue goes straight to the Decor products tab
        public IActionResult Index() => RedirectToAction(nameof(Products));

        public async Task<IActionResult> Products(string? search)
        {
            var model = await BuildModel(CatalogueItemType.Product, search);
            model.Tab = "Products";
            return View("Catalogue", model);
        }

        public async Task<IActionResult> Packages(string? search)
        {
            var model = await BuildModel(CatalogueItemType.Package, search);
            model.Tab = "Packages";
            return View("Catalogue", model);
        }

        private async Task<CatalogueViewModel> BuildModel(CatalogueItemType type, string? search)
        {
            var query = _db.CatalogueItems.Where(i => i.Type == type);

            if (!string.IsNullOrWhiteSpace(search))
            {
                // Like() makes the search ignore upper/lower case
                var pattern = $"%{search.Trim()}%";
                query = query.Where(i => EF.Functions.Like(i.Name, pattern)
                                      || EF.Functions.Like(i.Description, pattern));
            }

            return new CatalogueViewModel
            {
                Search = search,
                Items = await query.OrderBy(i => i.Name).ToListAsync()
            };
        }
    }
}

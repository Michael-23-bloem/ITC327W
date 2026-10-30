using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FirstWebApp.Controllers
{
    [Authorize]
    public class QuotesController : Controller
    {
        [HttpGet]
        public IActionResult Index()
        {
            ViewData["Title"] = "My Quotes";
            ViewData["Lead"] = "Your quotation requests and their progress will appear here.";

            var quotes = new List<QuoteListItem>
            {
                new QuoteListItem("AKEAEVENTS-2026-01", "Wedding",         new DateOnly(2026, 5, 12), 10060m,      "18h left",               false),
                new QuoteListItem("AKEAEVENTS-2026-02", "Birthday",        new DateOnly(2027, 3, 11),  6800m,      "Quotation approved",     true),
                new QuoteListItem("AKEAEVENTS-2026-03", "Baby Shower",     new DateOnly(2026, 8, 10),  5200m,      "Declined",               false),
                new QuoteListItem("AKEAEVENTS-2026-04", "Corporate Event", new DateOnly(2026,4, 09),   7450m,      "Awaiting deposit",       false),
                new QuoteListItem("AKEAEVENTS-2026-05", "Corporate Event", new DateOnly(2027,4, 08),   7450m,      "Preparations begun",     false),
            };
            return View(quotes);
        }
    }
}
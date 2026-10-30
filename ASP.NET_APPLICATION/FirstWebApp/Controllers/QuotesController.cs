using System.Security.Claims;
using FirstWebApp.Models;
using FirstWebApp.Services;
using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest;
using Supabase.Postgrest.Exceptions;

namespace FirstWebApp.Controllers
{
    [Authorize]
    public class QuotesController : Controller
    {
        private const string NewOrderStatus = "request_sent";   // what Flutter shows as a new request
        private const string NewQuoteStatus = "pending";

        private readonly Supabase.Client _supabase;
        private readonly SupabaseSessionService _session;
        private readonly EstimateService _estimate;
        private readonly ILogger<QuotesController> _logger;

        public QuotesController(Supabase.Client supabase, SupabaseSessionService session,
                                EstimateService estimate, ILogger<QuotesController> logger)
        {
            _supabase = supabase;
            _session = session;
            _estimate = estimate;
            _logger = logger;
        }

        // /Quotes (My Quotes): sample data for now, to be loaded from Supabase later
        [HttpGet]
        public IActionResult Index()
        {
            ViewData["Title"] = "My Quotes";

            var quotes = new List<QuoteListItem>
            {
                new QuoteListItem("AKEAEVENTS-2026-01", "Wedding",         new DateOnly(2026, 5, 12), 10060m, "18h left",           false),
                new QuoteListItem("AKEAEVENTS-2026-02", "Birthday",        new DateOnly(2027, 3, 11),  6800m, "Quotation approved", true),
                new QuoteListItem("AKEAEVENTS-2026-03", "Baby Shower",     new DateOnly(2026, 8, 10),  5200m, "Declined",           false),
                new QuoteListItem("AKEAEVENTS-2026-04", "Corporate Event", new DateOnly(2026, 4, 9),   7450m, "Awaiting deposit",   false),
                new QuoteListItem("AKEAEVENTS-2026-05", "Corporate Event", new DateOnly(2027, 4, 8),   7450m, "Preparations begun", false)
            };

            return View(quotes);
        }

        // GET /Quotes/Request
        [HttpGet]
        [ActionName("Request")]
        public async Task<IActionResult> RequestForm()
        {
            var lines = _estimate.GetLines();
            if (!lines.Any()) return EmptyEstimate();

            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain();

            return View("Request", new QuoteRequestViewModel { Lines = lines });
        }

        // POST /Quotes/Request
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ActionName("Request")]
        public async Task<IActionResult> SubmitRequest(QuoteRequestViewModel form)
        {
            form.Lines = _estimate.GetLines();
            if (!form.Lines.Any()) return EmptyEstimate();

            var earliest = DateTime.Today.AddDays(QuoteRequestViewModel.MinDaysAhead);
            if (form.EventDate.HasValue && form.EventDate.Value.Date < earliest)
            {
                ModelState.AddModelError(nameof(form.EventDate),
                    $"Please choose a date from {earliest:d MMMM yyyy}, so we have time to prepare.");
            }

            if (!ModelState.IsValid) return View("Request", form);

            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain();

            Guid? orderId = null;

            try
            {
                // 1. The request itself (needs assessment included in the notes)
                var order = (await _supabase.From<Order>().Insert(new Order
                {
                    CustomerId = CurrentCustomerId(),
                    EventType = form.EventType,
                    EventDate = form.EventDate!.Value.Date,
                    Venue = form.Venue?.Trim(),
                    Guests = form.Guests,
                    Notes = BuildNotes(form),
                    Status = NewOrderStatus
                })).Models.First();

                orderId = order.Id;

                // 2. The items (the database sets each unit price from the current price)
                var items = form.Lines.Select(l => new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = l.ItemType == CatalogueItemTypes.Product ? l.ItemId : null,
                    PackageId = l.ItemType == CatalogueItemTypes.Package ? l.ItemId : null,
                    Quantity = l.Quantity
                }).ToList();

                await _supabase.From<OrderItem>().Insert(items,
                    new QueryOptions { Returning = QueryOptions.ReturnType.Minimal });

                // Read the saved items back, so the total uses the database's prices
                var saved = (await _supabase.From<OrderItem>()
                    .Where(i => i.OrderId == order.Id)
                    .Get()).Models;

                // 3. The initial quotation for the owner to review in Flutter
                await _supabase.From<Quotation>().Insert(new Quotation
                {
                    OrderId = order.Id,
                    Version = 1,
                    Status = NewQuoteStatus,
                    EstimatedTotal = saved.Sum(i => i.UnitPrice * i.Quantity)
                }, new QueryOptions { Returning = QueryOptions.ReturnType.Minimal });

                _estimate.Clear();
                return RedirectToAction(nameof(Sent), new { id = order.Id });
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Submitting a quotation request failed (order {OrderId})", orderId);

                // Don't leave a half-saved request for the owner to find
                if (orderId.HasValue) await TryCancelAsync(orderId.Value);

                ModelState.AddModelError(string.Empty,
                    "We couldn't send your request right now. Please try again, or message us on WhatsApp.");
                return View("Request", form);
            }
        }

        // GET /Quotes/Sent/{id}
        public async Task<IActionResult> Sent(Guid id)
        {
            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain();

            var order = await _supabase.From<Order>().Where(o => o.Id == id).Single();
            if (order == null) return NotFound();

            var quote = await _supabase.From<Quotation>()
                .Where(q => q.OrderId == id)
                .Where(q => q.Version == 1)
                .Single();

            return View(new QuoteSentViewModel
            {
                Reference = ToReference(order.Id),
                EventType = order.EventType,
                EventDate = order.EventDate,
                Guests = order.Guests,
                EstimatedTotal = quote?.EstimatedTotal
            });
        }

        // ---------- Helpers ----------

        // The needs-assessment answers, followed by the customer's own notes
        private static string BuildNotes(QuoteRequestViewModel form)
        {
            var lines = new List<string>
            {
                $"Setup and take-down: {(form.NeedsSetup == true ? "Yes" : "No")}",
                $"Indoors or outdoors: {form.VenueSetting}",
                $"Delivery to venue: {(form.NeedsDelivery == true ? "Yes" : "No")}"
            };

            if (!string.IsNullOrWhiteSpace(form.ColourTheme)) lines.Add($"Colour theme: {form.ColourTheme.Trim()}");
            if (!string.IsNullOrWhiteSpace(form.BudgetRange)) lines.Add($"Budget range: {form.BudgetRange}");

            if (!string.IsNullOrWhiteSpace(form.Notes))
            {
                lines.Add("");
                lines.Add("Customer notes:");
                lines.Add(form.Notes.Trim());
            }

            return string.Join("\n", lines);
        }

        private async Task TryCancelAsync(Guid orderId)
        {
            try
            
            {
                await _supabase.From<Order>()
                    .Where(o => o.Id == orderId)
                    .Set(o => o.Status, "cancelled")
                    .Update();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Could not cancel the incomplete order {OrderId}", orderId);
            }
        }

        // A short, readable reference such as REQ-3F2A9C1B
        private static string ToReference(Guid id) => "REQ-" + id.ToString("N")[..8].ToUpperInvariant();

        private IActionResult EmptyEstimate()
        {
            TempData["Added"] = "Add some items to your estimate before requesting a quotation.";
            return RedirectToAction("Products", "Catalogue");
        }

        private Guid CurrentCustomerId() =>
            Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        private async Task<IActionResult> SignInAgain()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action("Request", "Quotes") });
        }
    }
}
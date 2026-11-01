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

        // /Quotes: My Quotes
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain(Url.Action(nameof(Index)));

            var items = new List<QuoteListItem>();

            try
            {
                var customerId = CurrentCustomerId();

                var orders = (await _supabase.From<Order>()
                    .Where(o => o.CustomerId == customerId)
                    .Order(o => o.CreatedAt, Constants.Ordering.Descending)
                    .Get()).Models;

                var latestQuotes = await LoadLatestQuotesAsync(orders.Select(o => o.Id).ToList());

                items = orders.Select(o =>
                {
                    latestQuotes.TryGetValue(o.Id, out var quote);
                    return new QuoteListItem(
                        o.Id,
                        ToReference(o.Id),
                        o.EventType ?? "Event",
                        DateOnly.FromDateTime(o.EventDate),
                        TotalFor(quote),
                        QuoteStatus.ListLabel(o.Status, o.DecisionDueAt),
                        QuoteStatus.NeedsAction(o.Status));
                }).ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading My Quotes failed");
                ViewData["Error"] = "We couldn't load your requests right now. Please try again in a moment.";
            }

            return View(items);
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
                    Notes = string.IsNullOrWhiteSpace(form.Notes) ? null : form.Notes.Trim(),
                    Theme = string.IsNullOrWhiteSpace(form.ColourTheme) ? null : form.ColourTheme.Trim(),
                    SetupRequired = form.NeedsSetup,
                    VenueSetting = form.VenueSetting?.ToLowerInvariant(),
                    DeliveryRequired = form.NeedsDelivery,
                    BudgetRange = string.IsNullOrWhiteSpace(form.BudgetRange) ? null : form.BudgetRange,
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

                // /Quotes/Details/{id}: one request, its latest quotation, payment details and progress
        public async Task<IActionResult> Details(Guid id)
        {
            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain(Url.Action(nameof(Details), new { id }));

            try
            {
                var order = await _supabase.From<Order>().Where(o => o.Id == id).Single();
                if (order == null || order.CustomerId != CurrentCustomerId()) return NotFound();

                // The latest quotation version
                var quote = (await _supabase.From<Quotation>()
                    .Where(q => q.OrderId == id)
                    .Order(q => q.Version, Constants.Ordering.Descending)
                    .Limit(1)
                    .Get()).Models.FirstOrDefault();

                var lines = await LoadLinesAsync(id);

                Deposit? deposit = null;
                if (quote != null)
                {
                    deposit = (await _supabase.From<Deposit>()
                        .Where(d => d.QuotationId == quote.Id)
                        .Order(d => d.CreatedAt, Constants.Ordering.Descending)
                        .Limit(1)
                        .Get()).Models.FirstOrDefault();
                }

                var updates = (await _supabase.From<OrderProgressUpdate>()
                    .Where(p => p.OrderId == id)
                    .Order(p => p.CreatedAt, Constants.Ordering.Descending)
                    .Get()).Models;

                var total = TotalFor(quote);

                var model = new QuoteDetailsViewModel
                {
                    Id = order.Id,
                    Reference = ToReference(order.Id),
                    Status = order.Status,
                    EventType = order.EventType,
                    EventDate = order.EventDate,
                    Venue = order.Venue,
                    Guests = order.Guests,
                    Notes = order.Notes,
                    Theme = order.Theme,
                    SetupRequired = order.SetupRequired,
                    VenueSetting = order.VenueSetting,
                    DeliveryRequired = order.DeliveryRequired,
                    BudgetRange = order.BudgetRange,
                    DecisionDueAt = order.DecisionDueAt,
                    Lines = lines,
                    QuoteVersion = quote?.Version,
                    QuoteStatus = quote?.Status,
                    ItemsSubtotal = quote?.EstimatedTotal ?? lines.Sum(l => l.LineTotal),
                    TransportationFee = quote?.TransportationFee ?? 0,
                    ServiceFee = quote?.ServiceFee ?? 0,
                    Total = total,
                    NoteToClient = quote?.NoteToClient,
                    BankingDetails = quote?.BankingDetails,
                    DeclineReason = quote?.DeclineReason,
                    // The deposit the owner recorded, or 50% of the total (as in the SRS)
                    DepositAmount = deposit?.Amount ?? (total.HasValue ? Math.Round(total.Value * 0.5m, 2) : null),
                    DepositStatus = deposit?.Status,
                    Updates = updates.Select(u => new ProgressUpdateViewModel
                    {
                        Message = u.Message,
                        CreatedAt = u.CreatedAt
                    }).ToList()
                };

                return View(model);
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading request {OrderId} failed", id);
                TempData["QuoteMessage"] = "We couldn't load that request right now. Please try again in a moment.";
                return RedirectToAction(nameof(Index));
            }
        }

        // Customers can cancel only while the request is still awaiting review
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Cancel(Guid id)
        {
            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain(Url.Action(nameof(Details), new { id }));

            try
            {
                var result = await _supabase.From<Order>()
                    .Where(o => o.Id == id)
                    .Where(o => o.Status == NewOrderStatus)
                    .Set(o => o.Status, "cancelled")
                    .Update();

                TempData["QuoteMessage"] = result.Models.Any()
                    ? "Your request has been cancelled."
                    : "This request can no longer be cancelled online. Please contact us on WhatsApp.";
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Cancelling request {OrderId} failed", id);
                TempData["QuoteMessage"] = "We couldn't cancel your request right now. Please try again.";
            }

            return RedirectToAction(nameof(Details), new { id });
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

        // The highest quotation version for each order
        private async Task<Dictionary<Guid, Quotation>> LoadLatestQuotesAsync(List<Guid> orderIds)
        {
            if (orderIds.Count == 0) return new();

            var quotes = (await _supabase.From<Quotation>()
                .Filter("order_id", Constants.Operator.In, orderIds.Select(id => id.ToString()).ToList())
                .Get()).Models;

            return quotes
                .GroupBy(q => q.OrderId)
                .ToDictionary(g => g.Key, g => g.OrderByDescending(q => q.Version).First());
        }

        // The request's items, with product and package names
        private async Task<List<QuoteLineViewModel>> LoadLinesAsync(Guid orderId)
        {
            var items = (await _supabase.From<OrderItem>()
                .Where(i => i.OrderId == orderId)
                .Get()).Models;

            var productIds = items.Where(i => i.ProductId.HasValue).Select(i => i.ProductId!.Value.ToString()).Distinct().ToList();
            var packageIds = items.Where(i => i.PackageId.HasValue).Select(i => i.PackageId!.Value.ToString()).Distinct().ToList();

            var names = new Dictionary<Guid, string>();

            if (productIds.Count > 0)
            {
                foreach (var p in (await _supabase.From<DecorProduct>()
                    .Filter("id", Constants.Operator.In, productIds).Get()).Models)
                {
                    names[p.Id] = p.Name;
                }
            }

            if (packageIds.Count > 0)
            {
                foreach (var p in (await _supabase.From<DecorPackage>()
                    .Filter("id", Constants.Operator.In, packageIds).Get()).Models)
                {
                    names[p.Id] = p.Name;
                }
            }

            return items.Select(i =>
            {
                var itemId = i.ProductId ?? i.PackageId!.Value;
                return new QuoteLineViewModel
                {
                    Name = names.TryGetValue(itemId, out var name) ? name : "Item no longer listed",
                    IsPackage = i.PackageId.HasValue,
                    Quantity = i.Quantity,
                    UnitPrice = i.UnitPrice
                };
            }).OrderBy(l => l.Name).ToList();
        }

        // The owner's final total if set, otherwise the estimate plus fees
        private static decimal? TotalFor(Quotation? quote)
        {
            if (quote == null) return null;
            if (quote.FinalTotal.HasValue) return quote.FinalTotal;
            if (!quote.EstimatedTotal.HasValue) return null;
            return quote.EstimatedTotal.Value + quote.TransportationFee + quote.ServiceFee;
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

        private async Task<IActionResult> SignInAgain(string? returnUrl = null)
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account", new { returnUrl = returnUrl ?? Url.Action("Request", "Quotes") });
        }
    }
}
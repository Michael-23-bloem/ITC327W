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
    public class EnquiriesController : Controller
    {
        // Must be one of the status values allowed in Supabase (see step 1)
        private const string NewStatus = "open";

        private readonly Supabase.Client _supabase;
        private readonly SupabaseSessionService _session;
        private readonly ILogger<EnquiriesController> _logger;

        public EnquiriesController(Supabase.Client supabase, SupabaseSessionService session, ILogger<EnquiriesController> logger)
        {
            _supabase = supabase;
            _session = session;
            _logger = logger;
        }

        // /Enquiries
        public async Task<IActionResult> Index()
        {
            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain();

            var model = new EnquiriesViewModel();
            await LoadEnquiriesAsync(model);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Send(EnquiriesViewModel form)
        {
            if (!await _session.UseCustomerSessionAsync()) return await SignInAgain();

            if (!ModelState.IsValid)
            {
                await LoadEnquiriesAsync(form);
                return View(nameof(Index), form);
            }

            try
            {
                await _supabase.From<Enquiry>().Insert(
                    new Enquiry
                    {
                        CustomerId = CurrentCustomerId(),
                        Message = form.Message.Trim(),
                        Status = NewStatus
                    },
                    new QueryOptions { Returning = QueryOptions.ReturnType.Minimal });

                TempData["EnquirySent"] = "Thanks! Your question has been sent. We usually reply within 24 hours.";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Saving an enquiry failed");
                ModelState.AddModelError(string.Empty, "We couldn't send your question right now. Please try again, or message us on WhatsApp.");
                await LoadEnquiriesAsync(form);
                return View(nameof(Index), form);
            }
        }

        private async Task LoadEnquiriesAsync(EnquiriesViewModel model)
        {
            try
            {
                var customerId = CurrentCustomerId();

                var rows = (await _supabase.From<Enquiry>()
                    .Where(e => e.CustomerId == customerId)
                    .Order(e => e.CreatedAt, Constants.Ordering.Descending)
                    .Get()).Models;

                model.Enquiries = rows.Select(e => new EnquiryItemViewModel
                {
                    Message = e.Message,
                    Response = e.Response,
                    CreatedAt = e.CreatedAt,
                    RespondedAt = e.RespondedAt
                }).ToList();
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading enquiries failed");
                model.Error = "We couldn't load your questions right now. Please try again in a moment.";
            }
        }

        private Guid CurrentCustomerId() =>
            Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        // The login cookie has no usable Supabase session (e.g. it's from before this update)
        private async Task<IActionResult> SignInAgain()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Index)) });
        }
    }
}
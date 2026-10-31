using FirstWebApp.Models;
using Microsoft.AspNetCore.Mvc;
using Supabase.Postgrest;
using Supabase.Postgrest.Exceptions;

namespace FirstWebApp.Controllers
{
    public class FaqsController : Controller
    {
        private readonly Supabase.Client _supabase;
        private readonly ILogger<FaqsController> _logger;

        public FaqsController(Supabase.Client supabase, ILogger<FaqsController> logger)
        {
            _supabase = supabase;
            _logger = logger;
        }

        // /Faqs
        public async Task<IActionResult> Index()
        {
            var faqs = new List<Faq>();

            try
            {
                faqs = (await _supabase.From<Faq>()
                    .Where(f => f.IsActive == true)
                    .Order(f => f.SortOrder, Constants.Ordering.Ascending)
                    .Get()).Models;
            }
            catch (Exception ex) when (ex is PostgrestException or HttpRequestException)
            {
                _logger.LogError(ex, "Loading FAQs failed");
                ViewData["Error"] = "We couldn't load the FAQs right now. Please try again in a moment.";
            }

            return View(faqs);
        }
    }
}
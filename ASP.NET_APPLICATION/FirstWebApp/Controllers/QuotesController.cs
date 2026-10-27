using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FirstWebApp.Controllers
{
    [Authorize]
    public class QuotesController : Controller
    {
        public IActionResult Index()
        {
            ViewData["Title"] = "My Quotes";
            ViewData["Lead"] = "Your quotation requests and their progress will appear here.";
            return View("ComingSoon");
        }
    }
}
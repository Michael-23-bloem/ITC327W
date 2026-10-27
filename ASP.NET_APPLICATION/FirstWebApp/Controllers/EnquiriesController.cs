using Microsoft.AspNetCore.Mvc;

namespace FirstWebApp.Controllers
{
    public class EnquiriesController : Controller
    {
        public IActionResult Index()
        {
            ViewData["Title"] = "Enquiries";
            ViewData["Lead"] = "Questions about your event? You'll be able to send them to us here.";
            return View("ComingSoon");
        }
    }
}
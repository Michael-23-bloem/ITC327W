using Microsoft.AspNetCore.Mvc;

namespace client_decor_app.Controllers
{
    public class EnquiriesController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}

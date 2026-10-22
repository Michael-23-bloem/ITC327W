using Microsoft.AspNetCore.Mvc;

namespace client_decor_app.Controllers
{
    public class AboutController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}

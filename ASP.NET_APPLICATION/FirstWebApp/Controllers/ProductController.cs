using FirstWebApp.Models;
using Microsoft.AspNetCore.Mvc;

namespace FirstWebApp.Controllers
{
    public class ProductController : Controller
    {
       public List<Product> products = new List<Product>()
        {
                new Product {Name = "Kayak", Price = 275M},
                new Product {Name = "Lifejacket", Price = 48.95M},
                new Product {Name = "Soccer ball", Price = 19.50M},
                new Product {Name = "Corner flag", Price = 34.95M}
         };

     
        public IActionResult Index()
        {
            return View(products);
        }

        public IActionResult Details
        {
           
        }

    }
}

    

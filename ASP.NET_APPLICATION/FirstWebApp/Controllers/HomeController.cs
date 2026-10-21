using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FirstWebApp.Models;
using Microsoft.AspNetCore.Mvc;

namespace FirstWebApp.Controllers
{
    public class HomeController : Controller
    {
        
        public HomeController()
        {
           
        }

        public async Task<IActionResult> Index()
        {
            return View();
        }

        public IActionResult Privacy() => View();
        [HttpGet]
        public IActionResult RsvpForm()
        {
            return View();
        }
        [HttpPost]
        public IActionResult RsvpForm(GuestResponse response)
        {
            
            if (response.WillAttend == true) 
            { return View(response); }


            response.Name = "Motheo";
            return View("Thanks",response);
        }
        public IActionResult Error()
        {
            return View();
        }
    }
}
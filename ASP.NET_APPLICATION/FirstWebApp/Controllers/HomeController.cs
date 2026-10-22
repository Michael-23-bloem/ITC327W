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
        
        public IActionResult Error()
        {
            return View();
        }
    }
}
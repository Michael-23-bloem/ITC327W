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
        private readonly IHttpClientFactory _httpClientFactory;
        public HomeController(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task<IActionResult> Index()
        {
            var client = _httpClientFactory.CreateClient();
            // Open-Meteo endpoint for London weather
            var response = await client.GetAsync("https://api.open-meteo.com/v1/forecast?latitude=51.5074&longitude=-0.1278&current_weather=true");

            if (response.IsSuccessStatusCode)
            {
                var jsonString = await response.Content.ReadAsStringAsync();
                // Parse or deserialize into a view model here
                ViewBag.WeatherData = jsonString;
            }

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
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
        private readonly Supabase.Client _supabase;
        public HomeController(Supabase.Client supabase)
        {
            _supabase = supabase;
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                await _supabase.InitializeAsync();
                
                ViewData["Status"] = "Connected to Supabase ✔";
            }
            catch (Exception ex)
            {
                ViewData["Status"] = $"Connection failed: {ex.Message}";
            }
            return View();
        }

        public IActionResult Privacy() => View();
        
        public IActionResult Error()
        {
            return View();
        }
    }
}
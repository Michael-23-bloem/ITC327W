using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Supabase.Gotrue;


namespace FirstWebApp.Controllers
{
    public class AccountController : Controller
    {
        private readonly Supabase.Client _supabase;
        public AccountController(Supabase.Client supabase) => _supabase = supabase;

        [HttpGet] public IActionResult Register() => View();

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> Register(RegisterViewModel model)
        {
            if (!ModelState.IsValid) return View(model);

            try
            {
                // Extra fields travel as user metadata; the DB trigger copies them into profiles
                var options = new SignUpOptions
                {
                    Data = new Dictionary<string, object>
                    {
                        ["first_name"] = model.FirstName,
                        ["last_name"] = model.LastName,
                        ["phone_number"] = model.Phone ?? "",
                        ["email"] = model.Email,
                        ["date_of_birth"] = model.DateOfBirth?.ToString("yyyy-MM-dd") ?? "",
                        ["role"] = model.Role
                    }
                };

                var session = await _supabase.Auth.SignUp(model.Email, model.Password, options);

                // With email confirmation enabled there is no session until the link is clicked
                if (session?.AccessToken is null)
                    return View("CheckEmail");

                await SignInCookie(session);
                return RedirectToAction("Index", "Home");
            }
            catch (Supabase.Gotrue.Exceptions.GotrueException ex)
            {
                ModelState.AddModelError("", ex.Message);
                return View(model);
            }
        }

        [HttpGet]
        public IActionResult Login(string? returnUrl = null)
            => View(new LoginViewModel { ReturnUrl = returnUrl });

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (!ModelState.IsValid) return View(model);

            try
            {
                var session = await _supabase.Auth.SignIn(model.Email, model.Password);
                await SignInCookie(session!);

                return Url.IsLocalUrl(model.ReturnUrl)
                    ? Redirect(model.ReturnUrl!)
                    : RedirectToAction("Index", "Home");
            }
            catch (Supabase.Gotrue.Exceptions.GotrueException)
            {
                ModelState.AddModelError("", "Invalid email or password.");
                return View(model);
            }
        }

        [Authorize, HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Index","Home");
        }

        private async Task SignInCookie(Session session)
        {
            var user = session.User!;
            var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id!),   // Supabase user UUID
            new(ClaimTypes.Email, user.Email ?? "")
        };

            var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(identity),
                new AuthenticationProperties { IsPersistent = true });
        }
    }
}


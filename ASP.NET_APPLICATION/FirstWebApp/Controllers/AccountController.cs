using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Supabase.Gotrue;
using Supabase.Gotrue.Exceptions;
using System.ComponentModel.DataAnnotations;
using FirstWebApp.Services;

namespace FirstWebApp.Controllers
{
    public class AccountController : Controller
    {
        private readonly Supabase.Client _supabase;
        private readonly SupabaseSessionService _session;
        private readonly ILogger<AccountController> _logger;

        public AccountController(Supabase.Client supabase, SupabaseSessionService session, ILogger<AccountController> logger)
        {
            _supabase = supabase;
            _session = session;
            _logger = logger;
        }

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
                    // Where the confirmation email link sends the customer afterwards
                    RedirectTo = Url.Action("Login", "Account", null, Request.Scheme),
                    Data = new Dictionary<string, object>
                    {
                        ["first_name"] = model.FirstName,
                        ["last_name"] = model.LastName,
                        ["phone_number"] = model.Phone ?? "",
                        ["email"] = model.Email,
                        // ["date_of_birth"] = model.DateOfBirth?.ToString("yyyy-MM-dd") ?? "",
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

        // ---------- Forgot password ----------

        [HttpGet]
        public IActionResult ForgotPassword() => View(new ForgotPasswordViewModel());

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordViewModel model)
        {
            if (!ModelState.IsValid) return View(model);

            try
            {
                await _supabase.Auth.ResetPasswordForEmail(new ResetPasswordForEmailOptions(model.Email.Trim())
                {
                    RedirectTo = Url.Action(nameof(ResetPassword), "Account", null, Request.Scheme)
                });
            }
            catch (Exception ex) when (ex is GotrueException or HttpRequestException)
            {
                // Logged, but not shown: the message below is the same either way
                _logger.LogWarning(ex, "Sending a password reset email failed");
            }

            // Same message whether or not the email has an account
            TempData["AuthMessage"] = "If an account exists for that email, we've sent you a link to reset your password.";
            return RedirectToAction(nameof(Login));
        }

        // The link in the reset email opens this page
        [HttpGet]
        public IActionResult ResetPassword() => View(new ResetPasswordViewModel());

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(ResetPasswordViewModel model)
        {
            if (string.IsNullOrEmpty(model.AccessToken) || string.IsNullOrEmpty(model.RefreshToken))
            {
                ModelState.AddModelError(string.Empty, "This reset link is invalid or has expired. Please request a new one.");
            }

            if (!ModelState.IsValid) return View(model);

            try
            {
                // Use the session from the email link, then save the new password
                await _supabase.Auth.SetSession(model.AccessToken!, model.RefreshToken!);
                await _supabase.Auth.Update(new UserAttributes { Password = model.Password });

                TempData["AuthMessage"] = "Your password has been changed. Sign in with your new password.";
                return RedirectToAction(nameof(Login));
            }
            catch (Exception ex) when (ex is GotrueException or HttpRequestException)
            {
                _logger.LogWarning(ex, "Resetting a password failed");
                ModelState.AddModelError(string.Empty,
                    "We couldn't change your password. The link may have expired, or the password isn't allowed. Please request a new link.");
                return View(model);
            }
        }

        // From the navbar profile card: Supabase emails a confirmation link to the new address
        [Authorize]
        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangeEmail(string? newEmail, string? returnUrl = null)
        {
            var back = Url.IsLocalUrl(returnUrl) ? returnUrl! : Url.Action("Index", "Home")!;
            newEmail = (newEmail ?? string.Empty).Trim();

            // Re-open the profile card on the page we return to, to show the result
            TempData["ProfileOpen"] = "true";

            if (newEmail.Length == 0 || !new EmailAddressAttribute().IsValid(newEmail))
            {
                TempData["ProfileMessage"] = "Please enter a valid email address.";
                return LocalRedirect(back);
            }

            if (string.Equals(newEmail, User.FindFirstValue(ClaimTypes.Email), StringComparison.OrdinalIgnoreCase))
            {
                TempData["ProfileMessage"] = "That's already your email address.";
                return LocalRedirect(back);
            }

            if (!await _session.UseCustomerSessionAsync())
            {
                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                TempData["AuthMessage"] = "Please sign in again to change your email.";
                return RedirectToAction(nameof(Login), new { returnUrl = back });
            }

            try
            {
                await _supabase.Auth.Update(new UserAttributes { Email = newEmail });
                TempData["ProfileMessage"] =
                    $"We've sent a confirmation link to {newEmail}. Your email will change once you click it, then please sign in again.";
            }
            catch (Exception ex) when (ex is GotrueException or HttpRequestException)
            {
                _logger.LogWarning(ex, "Changing a customer's email failed");
                TempData["ProfileMessage"] = "We couldn't change your email. It may already be used by another account.";
            }

            return LocalRedirect(back);
        }

        private async Task SignInCookie(Session session)
        {
            var user = session.User!;
            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id!),   // Supabase user UUID
                new(ClaimTypes.Email, user.Email ?? "")
            };

            // Name and phone number saved at registration (for the navbar profile card)
            string? Meta(string key) =>
                user.UserMetadata != null && user.UserMetadata.TryGetValue(key, out var value) ? value?.ToString() : null;

            if (!string.IsNullOrWhiteSpace(Meta("first_name"))) claims.Add(new(ClaimTypes.GivenName, Meta("first_name")!));
            if (!string.IsNullOrWhiteSpace(Meta("last_name"))) claims.Add(new(ClaimTypes.Surname, Meta("last_name")!));
            if (!string.IsNullOrWhiteSpace(Meta("phone_number"))) claims.Add(new(ClaimTypes.MobilePhone, Meta("phone_number")!));

            var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var properties = new AuthenticationProperties { IsPersistent = true };

            // Keep the Supabase session so later pages can act as this customer (needed for RLS)
            properties.StoreTokens(new[]
            {
                new AuthenticationToken { Name = "access_token", Value = session.AccessToken! },
                new AuthenticationToken { Name = "refresh_token", Value = session.RefreshToken! }
            });

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(identity),
                properties);
        }
    }
}


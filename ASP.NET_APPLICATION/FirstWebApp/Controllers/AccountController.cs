using FirstWebApp.ViewModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Supabase.Gotrue;
using Supabase.Gotrue.Exceptions;

namespace FirstWebApp.Controllers
{
    public class AccountController : Controller
    {
        private readonly Supabase.Client _supabase;
        private readonly ILogger<AccountController> _logger;

        // Short-lived cookies that remember the Google/Facebook sign-in while the customer is away
        private const string VerifierCookie = "akea_oauth_verifier";
        private const string ReturnUrlCookie = "akea_oauth_return";

        public AccountController(Supabase.Client supabase, ILogger<AccountController> logger)
        {
            _supabase = supabase;
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

        // ---------- Google / Facebook ----------

        [HttpPost, ValidateAntiForgeryToken]
        public async Task<IActionResult> ExternalLogin(string provider, string? returnUrl = null)
        {
            Constants.Provider? chosen = provider switch
            {
                "google" => Constants.Provider.Google,
                "facebook" => Constants.Provider.Facebook,
                _ => null
            };

            if (chosen == null) return BadRequest();

            try
            {
                var state = await _supabase.Auth.SignIn(chosen.Value, new SignInOptions
                {
                    FlowType = Constants.OAuthFlowType.PKCE,
                    RedirectTo = Url.Action(nameof(ExternalCallback), "Account", null, Request.Scheme)
                });

                // Remember the sign-in's secret (and where to return) for 10 minutes
                var cookie = new CookieOptions
                {
                    HttpOnly = true,
                    Secure = true,
                    SameSite = SameSiteMode.Lax,
                    MaxAge = TimeSpan.FromMinutes(10),
                    IsEssential = true
                };

                Response.Cookies.Append(VerifierCookie, state.PKCEVerifier!, cookie);
                if (Url.IsLocalUrl(returnUrl)) Response.Cookies.Append(ReturnUrlCookie, returnUrl!, cookie);

                // Off to Google / Facebook
                return Redirect(state.Uri.ToString());
            }
            catch (Exception ex) when (ex is GotrueException or HttpRequestException)
            {
                _logger.LogWarning(ex, "Starting {Provider} sign-in failed", provider);
                TempData["AuthMessage"] = "We couldn't connect to that sign-in option. Please try again or use your email and password.";
                return RedirectToAction(nameof(Login), new { returnUrl });
            }
        }

        // Google / Facebook send the customer back here
        [HttpGet]
        public async Task<IActionResult> ExternalCallback(string? code, string? error,
            [FromQuery(Name = "error_description")] string? errorDescription)
        {
            var verifier = Request.Cookies[VerifierCookie];
            var returnUrl = Request.Cookies[ReturnUrlCookie];
            Response.Cookies.Delete(VerifierCookie);
            Response.Cookies.Delete(ReturnUrlCookie);

            if (!string.IsNullOrEmpty(error) || string.IsNullOrEmpty(code) || string.IsNullOrEmpty(verifier))
            {
                _logger.LogWarning("External sign-in was not completed: {Error} {Description}", error, errorDescription);
                TempData["AuthMessage"] = "We couldn't sign you in with that account. Please try again or use your email and password.";
                return RedirectToAction(nameof(Login));
            }

            try
            {
                var session = await _supabase.Auth.ExchangeCodeForSession(verifier, code);
                if (session?.User == null)
                {
                    TempData["AuthMessage"] = "We couldn't sign you in with that account. Please try again.";
                    return RedirectToAction(nameof(Login));
                }

                await SignInCookie(session);

                return Url.IsLocalUrl(returnUrl) ? Redirect(returnUrl!) : RedirectToAction("Index", "Home");
            }
            catch (Exception ex) when (ex is GotrueException or HttpRequestException)
            {
                _logger.LogWarning(ex, "Completing external sign-in failed");
                TempData["AuthMessage"] = "We couldn't sign you in with that account. Please try again or use your email and password.";
                return RedirectToAction(nameof(Login));
            }
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


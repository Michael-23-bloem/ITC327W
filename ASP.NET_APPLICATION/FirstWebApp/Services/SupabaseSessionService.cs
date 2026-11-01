using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Supabase.Gotrue.Exceptions;

namespace FirstWebApp.Services
{
    // Hands the signed-in customer's Supabase session to this request's Supabase client,
    // so database requests are made as that customer and Row Level Security applies.
    public class SupabaseSessionService
    {
        private readonly Supabase.Client _supabase;
        private readonly IHttpContextAccessor _http;
        private readonly ILogger<SupabaseSessionService> _logger;

        public SupabaseSessionService(Supabase.Client supabase, IHttpContextAccessor http, ILogger<SupabaseSessionService> logger)
        {
            _supabase = supabase;
            _http = http;
            _logger = logger;
        }

        // Returns false if there's no usable session (the customer needs to sign in again)
        public async Task<bool> UseCustomerSessionAsync()
        {
            var context = _http.HttpContext;
            if (context?.User.Identity?.IsAuthenticated != true) return false;

            var auth = await context.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            var accessToken = auth.Properties?.GetTokenValue("access_token");
            var refreshToken = auth.Properties?.GetTokenValue("refresh_token");

            if (string.IsNullOrEmpty(accessToken) || string.IsNullOrEmpty(refreshToken)) return false;

            try
            {
                // Supabase renews the session automatically if it has expired
                var session = await _supabase.Auth.SetSession(accessToken, refreshToken);

                // If it was renewed, save the new tokens (the old ones stop working)
                if (session.AccessToken != accessToken && auth.Principal != null && auth.Properties != null)
                {
                    auth.Properties.UpdateTokenValue("access_token", session.AccessToken!);
                    auth.Properties.UpdateTokenValue("refresh_token", session.RefreshToken!);
                    await context.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, auth.Principal, auth.Properties);
                }

                return true;
            }
            catch (GotrueException ex)
            {
                _logger.LogWarning(ex, "Could not restore the customer's Supabase session");
                return false;
            }
        }
    }
}
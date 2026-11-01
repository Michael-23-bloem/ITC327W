using Microsoft.AspNetCore.Authentication.Cookies;
using Supabase.Extensions.DependencyInjection;
using FirstWebApp.Services;

namespace FirstWebApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllersWithViews();

            // Load .env file
            DotNetEnv.Env.Load();

            // Supabase client: scoped, so one user's session is never shared with another
            // Credentials must be in .env (SUPABASE_URL and SUPABASE_KEY)
            var supabaseUrl = Environment.GetEnvironmentVariable("SUPABASE_URL");
            var supabaseKey = Environment.GetEnvironmentVariable("SUPABASE_KEY");
            if (string.IsNullOrEmpty(supabaseUrl) || string.IsNullOrEmpty(supabaseKey))
            {
                throw new InvalidOperationException("Supabase credentials are missing. Add SUPABASE_URL and SUPABASE_KEY to .env file.");
            }
            builder.Services.AddSupabase(supabaseUrl, supabaseKey);

            builder.Services
                .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                 .AddCookie(o =>
                 {
                     o.LoginPath = "/Account/Login";
                     o.AccessDeniedPath = "/Account/Login";
                     o.ExpireTimeSpan = TimeSpan.FromHours(8);
                     o.SlidingExpiration = true;
                     o.Cookie.HttpOnly = true;
                     o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
                 });

            // Session: remembers each visitors estimate between pages
            builder.Services.AddDistributedMemoryCache();
            builder.Services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromHours(2);
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
            });
            builder.Services.AddHttpContextAccessor();
            builder.Services.AddScoped<EstimateService>();
            builder.Services.AddScoped<SupabaseSessionService>();
            
            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();
            app.UseSession();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Home}/{action=Index}/{id?}");

            app.Run();
        }
    }
}

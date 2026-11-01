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

            // Supabase client: scoped, so one user's session is never shared with another
            builder.Services.AddSupabase(
                 builder.Configuration["Supabase:Url"]!,
                 builder.Configuration["Supabase:Key"]!
            );

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

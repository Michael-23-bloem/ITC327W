namespace FirstWebApp.ViewModels
{
    public record Occasion(string Name, string Image);

    public record HomePackage(string Name, string Description, string FromPrice, string Image);

    public class HomeViewModel
    {
        public List<string> HeroSlides { get; set; } = new();
        public string AboutImage { get; set; } = string.Empty;
        public List<Occasion> Occasions { get; set; } = new();
        public List<HomePackage> Packages { get; set; } = new();

        // The latest events from the portfolio table in Supabase
        public List<PortfolioCardViewModel> Work { get; set; } = new();
    }
}
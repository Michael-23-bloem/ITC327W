namespace FirstWebApp.ViewModels
{
    public record Occasion(string Name, string Image);

    public record HomePackage(string Name, string Description, string FromPrice, string Image);

    public record WorkItem(string Title, string Meta, string Image);

    public class HomeViewModel
    {
        public List<string> HeroSlides { get; set; } = new();
        public string AboutImage { get; set; } = string.Empty;
        public List<Occasion> Occasions { get; set; } = new();
        public List<HomePackage> Packages { get; set; } = new();
        public List<WorkItem> Work { get; set; } = new();
    }
}
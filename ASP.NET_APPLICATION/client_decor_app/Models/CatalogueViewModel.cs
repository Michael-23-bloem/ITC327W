namespace client_decor_app.Models
{
    public class CatalogueViewModel
    {
        public string Tab { get; set; } = "Products";
        public string? Search { get; set; }
        public List<CatalogueItem> Items { get; set; } = new();
    }
}
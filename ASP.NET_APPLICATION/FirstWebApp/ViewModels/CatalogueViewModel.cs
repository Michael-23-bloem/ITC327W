namespace FirstWebApp.ViewModels
{
    // The two kinds of things a customer can add to their estimate
    public static class CatalogueItemTypes
    {
        public const string Product = "Product";
        public const string Package = "Package";
    }

        // One line in a package's "View items" dialog
    public class PackageContentViewModel
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public int Quantity { get; set; }
    }

    // What one catalogue card needs, for products and packages alike
    public class CatalogueItemViewModel
    {
        public Guid Id { get; set; }
        public string ItemType { get; set; } = CatalogueItemTypes.Product;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
        public string? Category { get; set; }

        // Only filled for packages: the products the package contains
        public List<PackageContentViewModel> Contents { get; set; } = new();
    }

    public class CatalogueViewModel
    {
        public string Tab { get; set; } = "Products";           // "Products" or "Packages"
        public string? Search { get; set; }
        public string? Category { get; set; }
        public List<string> Categories { get; set; } = new();
        public List<CatalogueItemViewModel> Items { get; set; } = new();
        public string? Error { get; set; }                       // shown if Supabase can't be reached
    }
}
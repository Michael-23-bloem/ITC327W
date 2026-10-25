using System.Text.Json;
using FirstWebApp.Models;

namespace FirstWebApp.Services
{
    // Keeps each visitors estimate in their session (no login needed)
    public class EstimateService
    {
        private const string SessionKey = "Estimate";
        private readonly IHttpContextAccessor _http;

        public EstimateService(IHttpContextAccessor http)
        {
            _http = http;
        }

        private ISession Session => _http.HttpContext!.Session;

        public List<EstimateLine> GetLines()
        {
            var json = Session.GetString(SessionKey);
            return json == null
                ? new List<EstimateLine>()
                : JsonSerializer.Deserialize<List<EstimateLine>>(json) ?? new List<EstimateLine>();
        }

        public int Count => GetLines().Sum(l => l.Quantity);

        public decimal Total => GetLines().Sum(l => l.LineTotal);

        public void Add(Guid itemId, string itemType, string name, decimal price, int quantity)
        {
            if (quantity < 1) return;

            var lines = GetLines();
            var existing = lines.FirstOrDefault(l => l.ItemId == itemId && l.ItemType == itemType);

            if (existing != null)
            {
                existing.Quantity += quantity;
                existing.Price = price;   // always use the latest price from Supabase
                existing.Name = name;
            }
            else
            {
                lines.Add(new EstimateLine
                {
                    ItemId = itemId,
                    ItemType = itemType,
                    Name = name,
                    Price = price,
                    Quantity = quantity
                });
            }

            Save(lines);
        }

        public void Remove(Guid itemId, string itemType)
        {
            var lines = GetLines();
            lines.RemoveAll(l => l.ItemId == itemId && l.ItemType == itemType);
            Save(lines);
        }

        public void Clear() => Session.Remove(SessionKey);

        private void Save(List<EstimateLine> lines) =>
            Session.SetString(SessionKey, JsonSerializer.Serialize(lines));
    }
}
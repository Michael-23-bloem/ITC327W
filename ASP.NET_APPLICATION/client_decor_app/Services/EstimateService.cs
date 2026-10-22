using System.Globalization;
using System.Text.Json;
using client_decor_app.Models;

namespace client_decor_app.Services
{
    // Keeps the visitor's estimate in their session (no login needed).
    public class EstimateService
    {
        private const string SessionKey = "Estimate";
        private const string DateKey = "EventDate";
        private readonly IHttpContextAccessor _http;

        public EstimateService(IHttpContextAccessor http)
        {
            _http = http;
        }

        private ISession Session => _http.HttpContext!.Session;

        // One event date per estimate, reused in the quote request
        public DateTime? EventDate
        {
            get => DateTime.TryParseExact(Session.GetString(DateKey), "yyyy-MM-dd",
                       CultureInfo.InvariantCulture, DateTimeStyles.None, out var d) ? d : null;
            set
            {
                if (value == null) Session.Remove(DateKey);
                else Session.SetString(DateKey, value.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture));
            }
        }

        public List<EstimateLine> GetLines()
        {
            var json = Session.GetString(SessionKey);
            return json == null
                ? new List<EstimateLine>()
                : JsonSerializer.Deserialize<List<EstimateLine>>(json) ?? new List<EstimateLine>();
        }

        public int Count => GetLines().Sum(l => l.Quantity);

        public decimal Total => GetLines().Sum(l => l.LineTotal);

        public void Add(CatalogueItem item, int quantity, bool notAvailable)
        {
            if (quantity < 1) return;

            var lines = GetLines();
            var existing = lines.FirstOrDefault(l => l.ItemId == item.Id && l.NotAvailable == notAvailable);

            if (existing != null)
            {
                existing.Quantity += quantity;
            }
            else
            {
                lines.Add(new EstimateLine
                {
                    ItemId = item.Id,
                    Name = item.Name,
                    Price = item.Price,
                    Quantity = quantity,
                    NotAvailable = notAvailable
                });
            }

            Save(lines);
        }

        public void Remove(int itemId)
        {
            var lines = GetLines();
            lines.RemoveAll(l => l.ItemId == itemId);
            Save(lines);
        }

        public void Clear()
        {
            Session.Remove(SessionKey);
            Session.Remove(DateKey);
        }

        private void Save(List<EstimateLine> lines)
        {
            Session.SetString(SessionKey, JsonSerializer.Serialize(lines));
        }
    }
}
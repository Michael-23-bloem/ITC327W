using client_decor_app.Data;
using Microsoft.EntityFrameworkCore;

namespace client_decor_app.Services
{
    public class AvailabilityService
    {
        private readonly AppDbContext _db;

        public AvailabilityService(AppDbContext db)
        {
            _db = db;
        }

        // How many of an item are free on a date: stock minus what's reserved
        public async Task<int> GetAvailableAsync(int itemId, DateTime eventDate)
        {
            var item = await _db.CatalogueItems.FindAsync(itemId);
            if (item == null) return 0;

            var date = eventDate.Date;
            var reserved = await _db.Reservations
                .Where(r => r.CatalogueItemId == itemId && r.EventDate == date)
                .SumAsync(r => r.Quantity);

            return Math.Max(0, item.StockQuantity - reserved);
        }
    }
}
namespace client_decor_app.Models
{
    // Items already booked for other events on a given date
    public class Reservation
    {
        public int Id { get; set; }
        public int CatalogueItemId { get; set; }
        public CatalogueItem? CatalogueItem { get; set; }
        public DateTime EventDate { get; set; }
        public int Quantity { get; set; }
    }
}
using System.ComponentModel.DataAnnotations;
using FirstWebApp.Models;

namespace FirstWebApp.ViewModels
{
    public class QuoteRequestViewModel
    {
        // How far ahead an event must be (change if AkeaEvents prefers another notice period)
        public const int MinDaysAhead = 3;

        public static readonly string[] EventTypes =
            { "Birthday", "Wedding", "Baby shower", "Corporate", "Kids party", "Other" };

        public static readonly string[] BudgetRanges =
            { "Under R5,000", "R5,000 – R10,000", "R10,000 – R20,000", "Over R20,000" };

        // ---------- 1. Event details ----------
        [Required(ErrorMessage = "Please choose the type of event.")]
        [Display(Name = "Event type")]
        public string? EventType { get; set; }

        [Required(ErrorMessage = "Please choose your event date.")]
        [DataType(DataType.Date)]
        [Display(Name = "Event date")]
        public DateTime? EventDate { get; set; }

        [Required(ErrorMessage = "Please enter the venue or address.")]
        [StringLength(200)]
        [Display(Name = "Venue / address")]
        public string? Venue { get; set; }

        [Required(ErrorMessage = "Please enter the number of guests.")]
        [Range(1, 2000, ErrorMessage = "Please enter between 1 and 2000 guests.")]
        [Display(Name = "Number of guests")]
        public int? Guests { get; set; }

        [StringLength(100)]
        [Display(Name = "Colour theme")]
        public string? ColourTheme { get; set; }

        [Display(Name = "Budget range")]
        public string? BudgetRange { get; set; }

        // ---------- 2. Needs assessment ----------
        [Required(ErrorMessage = "Please choose yes or no.")]
        public bool? NeedsSetup { get; set; }

        [Required(ErrorMessage = "Please choose indoors or outdoors.")]
        public string? VenueSetting { get; set; }

        [Required(ErrorMessage = "Please choose yes or no.")]
        public bool? NeedsDelivery { get; set; }

        [StringLength(2000)]
        [Display(Name = "Additional notes / inspiration")]
        public string? Notes { get; set; }

        // ---------- 3. Review (filled from the estimate, not the form) ----------
        public List<EstimateLine> Lines { get; set; } = new();
        public decimal Total => Lines.Sum(l => l.LineTotal);
    }

    public class QuoteSentViewModel
    {
        public string Reference { get; set; } = string.Empty;
        public string? EventType { get; set; }
        public DateTime EventDate { get; set; }
        public int? Guests { get; set; }
        public decimal? EstimatedTotal { get; set; }
    }
}
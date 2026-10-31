using System.Globalization;

namespace FirstWebApp.ViewModels
{
    // One row in the My Quotes table
    public record QuoteListItem(
        Guid Id,
        string OrderNumber,
        string EventType,
        DateOnly EventDate,
        decimal? Total,
        string StatusLabel,
        bool Highlight);

    // Formats rand amounts, e.g. R 10 060 or R 7 450,50
    public static class Money
    {
        public static string Rand(decimal amount)
        {
            var format = amount % 1 == 0 ? "N0" : "N2";
            return "R\u00A0" + amount.ToString(format, CultureInfo.InvariantCulture)
                .Replace(",", "\u00A0")
                .Replace(".", ",");
        }
    }

    // Everything the request details page shows
    public class QuoteDetailsViewModel
    {
        public Guid Id { get; set; }
        public string Reference { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? EventType { get; set; }
        public DateTime EventDate { get; set; }
        public string? Venue { get; set; }
        public int? Guests { get; set; }
        public string? Notes { get; set; }
        public string? Theme { get; set; }
        public bool? SetupRequired { get; set; }
        public string? VenueSetting { get; set; }
        public bool? DeliveryRequired { get; set; }
        public string? BudgetRange { get; set; }
        public DateTime? DecisionDueAt { get; set; }

        public List<QuoteLineViewModel> Lines { get; set; } = new();

        // The latest quotation (null if none yet)
        public int? QuoteVersion { get; set; }
        public string? QuoteStatus { get; set; }
        public decimal? ItemsSubtotal { get; set; }
        public decimal TransportationFee { get; set; }
        public decimal ServiceFee { get; set; }
        public decimal? Total { get; set; }
        public string? NoteToClient { get; set; }
        public string? BankingDetails { get; set; }
        public string? DeclineReason { get; set; }

        // Deposit
        public decimal? DepositAmount { get; set; }
        public string? DepositStatus { get; set; }

        public List<ProgressUpdateViewModel> Updates { get; set; } = new();

        public bool CanCancel => Status == "request_sent";
        public bool ShowPayment => Status is "quotation_approved" or "order_confirmed" && Total.HasValue;
    }

    public class QuoteLineViewModel
    {
        public string Name { get; set; } = string.Empty;
        public bool IsPackage { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal LineTotal => UnitPrice * Quantity;
    }

    public class ProgressUpdateViewModel
    {
        public string Message { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

        // Customer-friendly wording for the order statuses used by the database and the Flutter admin app
    public static class QuoteStatus
    {
        // The progress tracker stages, in order. They match how the admin app moves an order along:
        // request → owner in contact → quotation approved → deposit validated (becomes a booking) → preparations
        public static readonly (string Key, string Label)[] Stages =
        {
            ("request_sent", "Request sent"),
            ("in_contact", "In contact"),
            ("quotation_approved", "Quotation approved"),
            ("deposit_received", "Deposit received"),
            ("preparations_begin", "Preparations begun")
        };

        private static readonly Dictionary<string, string> OrderLabels = new()
        {
            ["request_sent"] = "Awaiting review",
            ["in_contact"] = "In contact with you",
            ["quotation_approved"] = "Quotation approved – pay deposit",
            ["order_confirmed"] = "Order confirmed – pay deposit",
            ["deposit_received"] = "Deposit received",
            ["preparations_begin"] = "Preparations begun",
            ["completed"] = "Completed",
            ["declined"] = "Declined",
            ["cancelled"] = "Cancelled"
        };

        private static readonly Dictionary<string, string> QuoteLabels = new()
        {
            ["pending"] = "Awaiting review",
            ["in_contact"] = "Being discussed",
            ["sent_back"] = "Revised quotation",
            ["confirmed"] = "Approved",
            ["declined"] = "Declined",
            ["superseded"] = "Replaced by a newer version"
        };

        public static string OrderLabel(string status) =>
            OrderLabels.TryGetValue(status, out var label) ? label : status;

        public static string QuoteLabel(string? status) =>
            status != null && QuoteLabels.TryGetValue(status, out var label) ? label : status ?? "";

        // "Awaiting review · 18h left" while the owner's 24-hour decision window is open
        public static string ListLabel(string status, DateTime? decisionDueAt)
        {
            if (status == "request_sent" && decisionDueAt.HasValue)
            {
                var hoursLeft = (int)Math.Ceiling((decisionDueAt.Value.ToUniversalTime() - DateTime.UtcNow).TotalHours);
                if (hoursLeft > 0) return $"Awaiting review · {hoursLeft}h left";
            }
            return OrderLabel(status);
        }

        // Highlight orders where the customer needs to pay the deposit
        public static bool NeedsAction(string status) =>
            status is "quotation_approved" or "order_confirmed";

        // Which tracker stage the order has reached:
        //   0–4 = that stage is current, 5 = completed (every stage ticked), -1 = declined or cancelled
        public static int StageIndex(string status) => status switch
        {
            "order_confirmed" => 2,              // not used by the admin flow; treated as "Quotation approved"
            "completed" => Stages.Length,        // all five stages done
            _ => Array.FindIndex(Stages, s => s.Key == status)
        };
    }
}
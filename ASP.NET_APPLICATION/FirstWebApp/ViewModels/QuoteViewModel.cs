using System.Globalization;
namespace FirstWebApp.ViewModels
    
{
    public record QuoteListItem(
       string OrderNumber,
       string EventType,
       DateOnly EventDate,
       decimal? Total,
       string StatusLabel,
       bool Highlight
       );
    public class QuoteViewModel
    {
    }

    public static class Money
    {
        public static string Rand(decimal amount)
        {
            var format = amount % 1 == 0 ? " " : "N2";
            return "R\u00A0" + amount.ToString(format, CultureInfo.InvariantCulture).Replace(",", "\u00A0").Replace(".", ",");
        }
    }
}

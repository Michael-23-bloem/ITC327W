using System.ComponentModel.DataAnnotations;

namespace FirstWebApp.ViewModels
{
    public class EnquiryItemViewModel
    {
        public string Message { get; set; } = string.Empty;
        public string? Response { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? RespondedAt { get; set; }

        public bool IsAnswered => !string.IsNullOrWhiteSpace(Response);
    }

    public class EnquiriesViewModel
    {
        // The new question form
        [Required(ErrorMessage = "Please write your question.")]
        [StringLength(2000, MinimumLength = 10, ErrorMessage = "Please write between 10 and 2000 characters.")]
        [Display(Name = "Your question")]
        public string Message { get; set; } = string.Empty;

        // The customer's earlier questions
        public List<EnquiryItemViewModel> Enquiries { get; set; } = new();

        public string? Error { get; set; }
    }
}
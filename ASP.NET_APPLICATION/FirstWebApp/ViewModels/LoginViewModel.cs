using System.ComponentModel.DataAnnotations;

namespace FirstWebApp.ViewModels
{
    public class LoginViewModel
    {
        [Required, EmailAddress] public string Email { get; set; } = "";
        [Required, DataType(DataType.Password)] public string Password { get; set; } = "";
        public string? ReturnUrl { get; set; }
    }
}

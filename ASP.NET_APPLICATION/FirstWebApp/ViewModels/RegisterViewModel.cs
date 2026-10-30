using System.ComponentModel.DataAnnotations;

namespace FirstWebApp.ViewModels
{
    public class RegisterViewModel
    {
        [Required, EmailAddress] public string Email { get; set; } = "";
        [Required, MinLength(8), DataType(DataType.Password)] public string Password { get; set; } = "";
        [Compare(nameof(Password)), DataType(DataType.Password)] public string ConfirmPassword { get; set; } = "";

        // Additional fields -> go into the profiles table
        [Required, Display(Name = "First name")] public string FirstName { get; set; } = "";
        [Required, Display(Name = "Last name")] public string LastName { get; set; } = "";
        [Phone] public string? Phone { get; set; }
        // [DataType(DataType.Date)] public DateTime? DateOfBirth { get; set; }
        public string Role { get; set; } = "User"; // Default role is "user"    
    }
}

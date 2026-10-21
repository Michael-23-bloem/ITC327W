
using System.ComponentModel.DataAnnotations;

namespace FirstWebApp.Models
{
    public class Product
    {
        [Required(ErrorMessage = "Pleae enter the product ID")]
        public int ProductID { get; set; }
        [Required(ErrorMessage = "Pleae enter your name.")]
        public string Name { get; set; }
        [Required(ErrorMessage = "Pleae enter the Description")]
        public string Description { get; set; }
        [Required(ErrorMessage = "Pleae enter the Price")]
        public decimal Price { get; set; }
        [Required(ErrorMessage = "Pleae enter the Category")]
        public string Category { set; get; }
    }
}

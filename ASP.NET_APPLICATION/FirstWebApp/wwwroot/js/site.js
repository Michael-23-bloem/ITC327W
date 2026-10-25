// Please see documentation at https://learn.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

// Quantity steppers on catalogue cards
document.addEventListener("click", function (e) {
    const button = e.target.closest(".qty-stepper button[data-step]");
    if (!button) return;

    const input = button.parentElement.querySelector("input[type='number']");
    const step = parseInt(button.dataset.step, 10);
    const min = parseInt(input.min || "1", 10);
    const max = parseInt(input.max || "999", 10);
    const next = (parseInt(input.value, 10) || min) + step;

    input.value = Math.min(max, Math.max(min, next));
});
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

// Package "View items" dialogs
document.addEventListener("click", function (e) {
    // Open the dialog named in data-open-dialog
    const opener = e.target.closest("[data-open-dialog]");
    if (opener) {
        const dialog = document.getElementById(opener.dataset.openDialog);
        if (dialog && typeof dialog.showModal === "function") {
            dialog.showModal();
        }
        return;
    }

    // A click on the dark area around an open dialog closes it
    if (e.target instanceof HTMLDialogElement && e.target.open) {
        const box = e.target.getBoundingClientRect();
        const clickedInside =
            e.clientX >= box.left && e.clientX <= box.right &&
            e.clientY >= box.top && e.clientY <= box.bottom;

        if (!clickedInside) {
            e.target.close();
        }
    }
});

// Portfolio gallery: clicking a thumbnail shows it as the main photo
document.addEventListener("click", function (e) {
    const thumb = e.target.closest(".gallery-thumb");
    if (!thumb) return;

    const main = document.getElementById("galleryMain");
    if (!main) return;

    main.src = thumb.dataset.src;
    document.querySelectorAll(".gallery-thumb").forEach(t => {
        const isCurrent = t === thumb;
        t.classList.toggle("active", isCurrent);
        t.setAttribute("aria-pressed", isCurrent ? "true" : "false");
    });
});

// Portfolio details: "View all" items used
document.addEventListener("click", function (e) {
    const button = e.target.closest("[data-toggle-items]");
    if (!button) return;

    const list = document.getElementById(button.getAttribute("aria-controls"));
    if (!list) return;

    const expand = button.getAttribute("aria-expanded") !== "true";
    list.querySelectorAll(".is-extra").forEach(item => { item.hidden = !expand; });

    button.setAttribute("aria-expanded", expand ? "true" : "false");
    button.textContent = expand ? "Show fewer" : button.dataset.label;
});

// Floating Décor Assistant (placeholder): open and close the panel.
// The floating button toggles it; any element with data-assistant-open opens it.
(function () {
    const panel = document.getElementById("assistantPanel");
    const toggle = document.querySelector("[data-assistant-toggle]");
    if (!panel || !toggle) return;

    const closeButton = panel.querySelector("[data-assistant-close]");
    let returnFocusTo = toggle;

    function setOpen(open, opener) {
        panel.hidden = !open;
        toggle.setAttribute("aria-expanded", open ? "true" : "false");

        if (open) {
            returnFocusTo = opener || toggle;
            closeButton?.focus();
        } else {
            returnFocusTo?.focus();
        }
    }

    document.addEventListener("click", e => {
        if (e.target.closest("[data-assistant-toggle]")) {
            setOpen(panel.hidden, toggle);
            return;
        }

        const opener = e.target.closest("[data-assistant-open]");
        if (opener) setOpen(true, opener);
    });

    closeButton?.addEventListener("click", () => setOpen(false));

    document.addEventListener("keydown", e => {
        if (e.key === "Escape" && !panel.hidden) setOpen(false);
    });
})();
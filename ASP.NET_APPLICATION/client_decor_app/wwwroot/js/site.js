// Quantity steppers (catalogue cards and the availability dialog)
document.addEventListener("click", function (e) {
    const button = e.target.closest(".qty-stepper button[data-step]");
    if (!button) return;

    const input = button.parentElement.querySelector("input[type='number']");
    const step = parseInt(button.dataset.step, 10);
    const min = parseInt(input.min || "1", 10);
    const max = parseInt(input.max || "999", 10);
    const next = (parseInt(input.value, 10) || min) + step;

    input.value = Math.min(max, Math.max(min, next));
    input.dispatchEvent(new Event("change", { bubbles: true }));
});

// "Check availability" dialog
(function () {
    const modalEl = document.getElementById("availabilityModal");
    if (!modalEl) return;

    const modal = new bootstrap.Modal(modalEl);
    const el = (id) => document.getElementById(id);
    const dateInput = el("avDate");
    const qtyInput = el("avQty");
    const status = el("avStatus");
    const options = el("avOptions");
    const addAvailable = el("avAddAvailable");
    const addRequested = el("avAddRequested");
    const tryDate = el("avTryDate");
    const ask = el("avAsk");
    let itemId = null;
    let requestId = 0;

    // Open the dialog from a catalogue card
    document.addEventListener("click", function (e) {
        const btn = e.target.closest(".js-check-availability");
        if (!btn) return;

        itemId = btn.dataset.itemId;
        el("avItemId").value = itemId;
        el("avName").textContent = btn.dataset.name;
        el("avPrice").textContent = "R " + btn.dataset.price + " each";

        const img = el("avImage");
        img.style.backgroundImage = btn.dataset.image ? `url('${btn.dataset.image}')` : "";
        img.textContent = btn.dataset.image ? "" : "No image yet";

        const cardQty = btn.closest(".item-actions").querySelector("input[name='quantity']");
        qtyInput.value = cardQty ? cardQty.value : 1;

        modal.show();
        check();
    });

    dateInput.addEventListener("change", check);
    qtyInput.addEventListener("change", check);

    tryDate.addEventListener("click", function () {
        dateInput.focus();
        if (dateInput.showPicker) dateInput.showPicker();
    });

    function setStatus(html, kind) {
        status.className = "av-status av-status--" + kind;
        status.innerHTML = html;
    }

    function formatDate(value) {
        return new Date(value + "T00:00:00").toLocaleDateString("en-ZA", {
            day: "numeric", month: "short", year: "numeric"
        });
    }

    async function check() {
        const date = dateInput.value;
        const qty = Math.max(1, parseInt(qtyInput.value, 10) || 1);
        options.hidden = true;

        if (!date) {
            setStatus("Choose your event date to check stock.", "info");
            return;
        }

        const thisRequest = ++requestId;
        setStatus("Checking stock…", "info");

        try {
            const res = await fetch(`/Estimate/Availability?itemId=${itemId}&date=${date}`);
            if (thisRequest !== requestId) return; // a newer check started

            if (!res.ok) {
                setStatus("Choose a date after today.", "error");
                return;
            }

            const data = await res.json();
            render(data.available, qty, formatDate(date));
        } catch {
            if (thisRequest === requestId) {
                setStatus("Couldn't check stock. Check your connection and try again.", "error");
            }
        }
    }

    function render(available, qty, dateText) {
        ask.href = `/Enquiries?itemId=${itemId}&date=${dateInput.value}`;
        options.hidden = false;

        if (available >= qty) {
            setStatus(`<strong>All ${qty} available on ${dateText}</strong>`, "ok");
            addAvailable.textContent = `Add ${qty} to estimate`;
            addAvailable.hidden = false;
            tryDate.hidden = ask.hidden = addRequested.hidden = true;
            return;
        }

        tryDate.hidden = ask.hidden = addRequested.hidden = false;
        addRequested.textContent = `Add ${qty} to estimate (not available)`;

        if (available > 0) {
            setStatus(
                `<strong>Only ${available} available on ${dateText}</strong><br>` +
                `You asked for ${qty}. The other ${qty - available} are reserved for other events. Choose an option below.`,
                "warn");
            addAvailable.textContent = `Add ${available} to estimate`;
            addAvailable.hidden = false;
        } else {
            setStatus(
                `<strong>None available on ${dateText}</strong><br>` +
                `All are reserved for other events. Choose an option below.`,
                "warn");
            addAvailable.hidden = true;
        }
    }
})();

// Portfolio gallery: clicking a thumbnail shows it as the main photo
document.addEventListener("click", function (e) {
    const thumb = e.target.closest(".gallery-thumb");
    if (!thumb) return;

    const main = document.getElementById("galleryMain");
    if (!main) return;

    main.src = thumb.dataset.src;
    document.querySelectorAll(".gallery-thumb")
        .forEach(t => t.classList.toggle("active", t === thumb));
});
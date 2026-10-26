// Home page hero slideshow
(function () {
    const hero = document.querySelector("[data-slideshow]");
    if (!hero) return;

    const slides = Array.from(hero.querySelectorAll(".slide"));
    const dots = Array.from(hero.querySelectorAll(".dot"));
    if (slides.length < 2) return;

    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    let current = 0;
    let timer = null;

    function show(index) {
        current = (index + slides.length) % slides.length;
        slides.forEach((slide, i) => slide.classList.toggle("active", i === current));
        dots.forEach((dot, i) => {
            dot.classList.toggle("active", i === current);
            dot.setAttribute("aria-current", i === current ? "true" : "false");
        });
    }

    function start() {
        if (!reduceMotion && !timer) {
            timer = setInterval(() => show(current + 1), 6000);
        }
    }

    function stop() {
        clearInterval(timer);
        timer = null;
    }

    dots.forEach((dot, i) => dot.addEventListener("click", () => {
        stop();
        show(i);
        start();
    }));

    hero.addEventListener("mouseenter", stop);
    hero.addEventListener("mouseleave", start);
    hero.addEventListener("focusin", stop);
    hero.addEventListener("focusout", start);

    show(0);
    start();
})();
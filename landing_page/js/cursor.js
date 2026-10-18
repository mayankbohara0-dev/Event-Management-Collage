/* ==========================================================================
   ZEST CUSTOM CURSOR & CARD TILT CONTROLLER
   Smooth 60fps, zero layout thrashing, desktop only
   ========================================================================== */

(function () {
  // Only enable on desktop with fine pointer
  if (window.matchMedia("(hover: none) or (pointer: coarse)").matches) return;
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

  const cursor = document.createElement("div");
  cursor.className = "custom-cursor";
  document.body.appendChild(cursor);

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let posX = mouseX;
  let posY = mouseY;

  window.addEventListener("mousemove", (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
  }, { passive: true });

  function renderCursor() {
    posX += (mouseX - posX) * 0.2;
    posY += (mouseY - posY) * 0.2;
    cursor.style.transform = `translate3d(${posX}px, ${posY}px, 0) translate(-50%, -50%)`;
    requestAnimationFrame(renderCursor);
  }
  requestAnimationFrame(renderCursor);

  // Magnetic & hover effect on interactive elements
  const hoverTargets = document.querySelectorAll("a, button, .tilt-card, .faq-question, .sticker, input");
  hoverTargets.forEach((target) => {
    target.addEventListener("mouseenter", () => cursor.classList.add("hover"));
    target.addEventListener("mouseleave", () => cursor.classList.remove("hover"));
  });

  // Optimized Card Tilt & Glow (attached per card, zero global query thrashing)
  const cards = document.querySelectorAll(".tilt-card");
  cards.forEach((card) => {
    let ticking = false;
    let cardRect = null;

    card.addEventListener("mouseenter", () => {
      cardRect = card.getBoundingClientRect();
    });

    card.addEventListener("pointermove", (e) => {
      if (!cardRect) cardRect = card.getBoundingClientRect();
      const x = e.clientX - cardRect.left;
      const y = e.clientY - cardRect.top;

      if (!ticking) {
        requestAnimationFrame(() => {
          card.style.setProperty("--mouse-x", `${x}px`);
          card.style.setProperty("--mouse-y", `${y}px`);

          // Gentle tilt calculation
          const cx = cardRect.width / 2;
          const cy = cardRect.height / 2;
          const tiltX = ((y - cy) / cy) * -4.5;
          const tiltY = ((x - cx) / cx) * 4.5;

          card.style.transform = `perspective(800px) rotateX(${tiltX}deg) rotateY(${tiltY}deg) scale3d(1.015, 1.015, 1.015)`;
          ticking = false;
        });
        ticking = true;
      }
    }, { passive: true });

    card.addEventListener("mouseleave", () => {
      cardRect = null;
      card.style.transform = "perspective(800px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)";
    });
  });
})();

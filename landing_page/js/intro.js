/* ==========================================================================
   ZEST LOGO INTRO LOADER (FLIP-Style into Navbar, < 1.2s total)
   ========================================================================== */

(function () {
  const intro = document.getElementById("intro-screen");
  const introCard = document.getElementById("intro-icon-card");
  const targetLogo = document.getElementById("nav-target-logo");
  if (!intro || !introCard) return;

  const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const alreadySeen = sessionStorage.getItem("zest_intro_seen");

  function dismissIntro() {
    intro.classList.add("fade-out");
    sessionStorage.setItem("zest_intro_seen", "true");
    setTimeout(() => {
      intro.style.display = "none";
    }, 400);
  }

  // Skip immediately on click
  intro.addEventListener("click", dismissIntro);

  if (prefersReducedMotion || alreadySeen) {
    intro.style.display = "none";
    return;
  }

  // Step 1: Slide giant Z and pop sparkle
  setTimeout(() => {
    introCard.classList.add("locked");
  }, 80);

  // Step 2: FLIP Animation into Navbar Logo
  setTimeout(() => {
    if (targetLogo) {
      const startRect = introCard.getBoundingClientRect();
      const endRect = targetLogo.getBoundingClientRect();

      const dx = (endRect.left + endRect.width / 2) - (startRect.left + startRect.width / 2);
      const dy = (endRect.top + endRect.height / 2) - (startRect.top + startRect.height / 2);
      const scale = endRect.width / startRect.width;

      introCard.style.transform = `translate(${dx}px, ${dy}px) scale(${scale})`;
      introCard.style.borderRadius = "12px";
      introCard.style.boxShadow = "0 2px 10px rgba(184, 255, 26, 0.4)";
    }

    setTimeout(() => {
      dismissIntro();
    }, 280);
  }, 640);
})();

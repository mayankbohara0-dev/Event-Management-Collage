/* ==========================================================================
   ZEST MAIN CONTROLLER
   Theme toggle, Mobile Nav, FAQ Accordion, OS Detection
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  // Add js-ready class immediately to prevent any flash of hidden content
  document.documentElement.classList.add("js-ready");

  // ── 1. Dark / Light Theme Toggle with Circular Reveal ────────────────────
  const themeToggle = document.getElementById("theme-toggle");
  const currentTheme = localStorage.getItem("zest_theme") || "light";

  if (currentTheme === "dark") {
    document.documentElement.setAttribute("data-theme", "dark");
  }

  if (themeToggle) {
    themeToggle.addEventListener("click", () => {
      const active = document.documentElement.getAttribute("data-theme");
      const nextTheme = active === "dark" ? "light" : "dark";

      if (document.startViewTransition && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
        const rect = themeToggle.getBoundingClientRect();
        const x = rect.left + rect.width / 2;
        const y = rect.top + rect.height / 2;
        const endRadius = Math.hypot(
          Math.max(x, window.innerWidth - x),
          Math.max(y, window.innerHeight - y)
        );

        const transition = document.startViewTransition(() => {
          document.documentElement.setAttribute("data-theme", nextTheme);
          localStorage.setItem("zest_theme", nextTheme);
        });

        transition.ready.then(() => {
          document.documentElement.animate(
            {
              clipPath: [
                `circle(0px at ${x}px ${y}px)`,
                `circle(${endRadius}px at ${x}px ${y}px)`
              ]
            },
            {
              duration: 450,
              easing: "cubic-bezier(0.16, 1, 0.3, 1)",
              pseudoElement: "::view-transition-new(root)"
            }
          );
        });
      } else {
        document.documentElement.setAttribute("data-theme", nextTheme);
        localStorage.setItem("zest_theme", nextTheme);
      }
    });
  }

  // ── 2. Mobile Nav Fullscreen Toggle ──────────────────────────────────────
  const mobileNavToggle = document.getElementById("mobile-nav-toggle");
  const mobileNavClose = document.getElementById("mobile-nav-close");
  const mobileNavMenu = document.getElementById("mobile-nav-menu");
  const mobileNavLinks = document.querySelectorAll(".mobile-nav-link");

  function openMobileNav() {
    if (!mobileNavMenu) return;
    mobileNavMenu.classList.add("open");
    mobileNavMenu.setAttribute("aria-hidden", "false");
    if (mobileNavToggle) mobileNavToggle.setAttribute("aria-expanded", "true");
    document.body.style.overflow = "hidden";
  }

  function closeMobileNav() {
    if (!mobileNavMenu) return;
    mobileNavMenu.classList.remove("open");
    mobileNavMenu.setAttribute("aria-hidden", "true");
    if (mobileNavToggle) mobileNavToggle.setAttribute("aria-expanded", "false");
    document.body.style.overflow = "";
  }

  if (mobileNavToggle) {
    mobileNavToggle.addEventListener("click", () => {
      const isOpen = mobileNavMenu && mobileNavMenu.classList.contains("open");
      if (isOpen) {
        closeMobileNav();
      } else {
        openMobileNav();
      }
    });
  }

  if (mobileNavClose) {
    mobileNavClose.addEventListener("click", closeMobileNav);
  }

  mobileNavLinks.forEach((link) => {
    link.addEventListener("click", closeMobileNav);
  });

  // Close on Escape
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && mobileNavMenu && mobileNavMenu.classList.contains("open")) {
      closeMobileNav();
    }
  });

  // ── 3. FAQ Accordion ─────────────────────────────────────────────────────
  const faqItems = document.querySelectorAll(".faq-item");
  faqItems.forEach((item) => {
    const questionBtn = item.querySelector(".faq-question");
    if (!questionBtn) return;

    questionBtn.addEventListener("click", () => {
      const isOpen = item.classList.contains("open");
      // Close all
      faqItems.forEach((f) => f.classList.remove("open"));
      // Toggle clicked item
      if (!isOpen) {
        item.classList.add("open");
      }
    });
  });

  // ── 4. OS Detection for Primary Download CTA ─────────────────────────────
  const userAgent = navigator.userAgent || navigator.vendor || window.opera;
  const isIOS = /iPad|iPhone|iPod/.test(userAgent) && !window.MSStream;
  const downloadBtns = document.querySelectorAll("[data-download-os]");

  downloadBtns.forEach((btn) => {
    const os = btn.getAttribute("data-download-os");
    if (isIOS && os === "ios") {
      btn.classList.add("btn-primary");
      btn.classList.remove("btn-secondary");
    } else if (!isIOS && os === "android") {
      btn.classList.add("btn-primary");
      btn.classList.remove("btn-secondary");
    }
  });

  // ── 5. Smooth Scroll for Anchor Links with Nav Offset ────────────────────
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (e) {
      const targetId = this.getAttribute("href");
      if (targetId === "#") return;
      const targetEl = document.querySelector(targetId);
      if (targetEl) {
        e.preventDefault();
        const navHeight = 90;
        const targetPos = targetEl.getBoundingClientRect().top + window.scrollY - navHeight;
        window.scrollTo({
          top: targetPos,
          behavior: "smooth",
        });
      }
    });
  });
});

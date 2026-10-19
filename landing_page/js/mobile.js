/* ==========================================================================
   ZEST MOBILE JS ENHANCEMENTS
   - Page visibility API -> pause marquee
   - body.nav-open -> hide sticky bar while menu open
   - Disable parallax on touch devices
   - Smart scroll offset for anchor links on mobile
   - Sticky bar hides when final CTA is visible
   ========================================================================== */

(function () {
  const isTouchDevice = window.matchMedia("(hover: none) or (pointer: coarse)").matches;

  /* ---- 1. PAGE VISIBILITY: pause marquees when tab is hidden ------------ */
  document.addEventListener("visibilitychange", () => {
    if (document.hidden) {
      document.body.classList.add("page-hidden");
    } else {
      document.body.classList.remove("page-hidden");
    }
  });

  /* ---- 2. body.nav-open class (hides sticky bar while menu is open) ----- */
  const mobileNavToggle = document.getElementById("mobile-nav-toggle");
  const mobileNavClose  = document.getElementById("mobile-nav-close");
  const mobileNavMenu   = document.getElementById("mobile-nav-menu");

  function setNavOpen(open) {
    document.body.classList.toggle("nav-open", open);
  }

  if (mobileNavToggle) {
    mobileNavToggle.addEventListener("click", () => {
      const isOpen = mobileNavMenu && mobileNavMenu.classList.contains("open");
      setNavOpen(!isOpen);
    });
  }
  if (mobileNavClose) {
    mobileNavClose.addEventListener("click", () => setNavOpen(false));
  }
  // Close on link tap
  document.querySelectorAll(".mobile-nav-link").forEach((link) => {
    link.addEventListener("click", () => setNavOpen(false));
  });
  // Close on Esc
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") setNavOpen(false);
  });
  // Close on outside tap
  if (mobileNavMenu) {
    mobileNavMenu.addEventListener("click", (e) => {
      if (e.target === mobileNavMenu) {
        setNavOpen(false);
        mobileNavMenu.classList.remove("open");
        mobileNavMenu.setAttribute("aria-hidden", "true");
        if (mobileNavToggle) mobileNavToggle.setAttribute("aria-expanded", "false");
        document.body.style.overflow = "";
      }
    });
  }

  /* ---- 3. Disable parallax on touch devices ----------------------------- */
  if (isTouchDevice) {
    // Prevent scroll.js from running parallax transforms on the hero Z and phone
    const heroZ     = document.querySelector(".hero-giant-z-wrap");
    const heroPhone = document.querySelector(".phone-primary");
    // We override with transform: none via CSS (mobile.css), but also
    // clear any inline styles set by scroll.js on scroll:
    window.addEventListener("scroll", () => {
      if (heroZ && heroZ.style.transform)    heroZ.style.transform    = "";
      if (heroPhone && heroPhone.style.transform) heroPhone.style.transform = "";
    }, { passive: true });
  }

  /* ---- 4. Sticky bar hides when final CTA section is in view ------------ */
  const stickyBar = document.getElementById("mobile-sticky-bar");
  const finalCTA  = document.getElementById("download");

  if (stickyBar && finalCTA) {
    const ctaObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          stickyBar.classList.remove("visible");
        }
      });
    }, { threshold: 0.2 });
    ctaObserver.observe(finalCTA);
  }

  /* ---- 5. Smooth scroll: correct offset for mobile sticky navbar -------- */
  // main.js already does this at navHeight=90, but on mobile the nav is
  // smaller (~60px). We patch by recalculating dynamically.
  if (isTouchDevice) {
    document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
      // Remove any existing listener added by main.js by cloning
      // (we can't easily do that, so we just add our own and rely on e.preventDefault)
      anchor.addEventListener("click", function (e) {
        const targetId = this.getAttribute("href");
        if (targetId === "#") return;
        const targetEl = document.querySelector(targetId);
        if (targetEl) {
          e.preventDefault();
          e.stopPropagation();
          const navEl = document.querySelector(".navbar");
          const navHeight = navEl ? navEl.getBoundingClientRect().height + 16 : 72;
          const targetPos = targetEl.getBoundingClientRect().top + window.scrollY - navHeight;
          window.scrollTo({ top: targetPos, behavior: "smooth" });
        }
      }, { capture: true }); // capture: true runs before main.js listener
    });
  }

})();

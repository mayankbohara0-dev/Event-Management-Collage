/* ==========================================================================
   ZEST SCROLL INTERACTIONS, PARALLAX & STEP PINNING
   ========================================================================== */

(function () {
  const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // ── 1. Navbar Blur, Hide on Scroll Down & Return on Scroll Up ──────────
  const navbarWrap = document.getElementById("navbar-wrap");
  const navbar = document.querySelector(".navbar");
  const stickyBar = document.getElementById("mobile-sticky-bar");
  const heroSection = document.getElementById("hero");
  let lastScrollY = window.scrollY;

  window.addEventListener("scroll", () => {
    const scrollY = window.scrollY;
    const delta = scrollY - lastScrollY;

    if (navbar) {
      if (scrollY > 40) {
        navbar.classList.add("scrolled");
      } else {
        navbar.classList.remove("scrolled");
      }
    }

    if (navbarWrap && scrollY > 150) {
      if (delta > 8) {
        navbarWrap.classList.add("nav-hidden");
      } else if (delta < -8) {
        navbarWrap.classList.remove("nav-hidden");
      }
    } else if (navbarWrap) {
      navbarWrap.classList.remove("nav-hidden");
    }

    if (stickyBar && heroSection) {
      const heroBottom = heroSection.getBoundingClientRect().bottom;
      if (heroBottom < 100) {
        stickyBar.classList.add("visible");
      } else {
        stickyBar.classList.remove("visible");
      }
    }

    lastScrollY = scrollY;
  }, { passive: true });

  // ── 1b. Active Navigation Section Spy ─────────────────────────────────────
  const sections = document.querySelectorAll("section[id]");
  const navLinks = document.querySelectorAll(".nav-link");

  if (sections.length > 0 && navLinks.length > 0) {
    const navObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute("id");
          navLinks.forEach((link) => {
            if (link.getAttribute("href") === `#${id}`) {
              link.classList.add("active");
            } else {
              link.classList.remove("active");
            }
          });
        }
      });
    }, { threshold: 0.35 });

    sections.forEach((s) => navObserver.observe(s));
  }

  if (prefersReduced) return;

  // ── 2. Scroll-Scrubbed Statement Word Reveal ────────────────────────────
  const statementWords = document.querySelectorAll(".statement-word");
  const statementSection = document.getElementById("statement");

  if (statementSection && statementWords.length > 0) {
    window.addEventListener("scroll", () => {
      const rect = statementSection.getBoundingClientRect();
      const windowH = window.innerHeight;

      // Calculate progress through the section
      const progress = Math.min(1, Math.max(0, (windowH * 0.8 - rect.top) / (rect.height * 0.75)));
      const wordsToLight = Math.floor(progress * statementWords.length);

      statementWords.forEach((word, idx) => {
        if (idx <= wordsToLight) {
          word.classList.add("lit");
        } else {
          word.classList.remove("lit");
        }
      });
    }, { passive: true });
  }

  // ── 3. How It Works Step Tracker ─────────────────────────────────────────
  const howSteps = document.querySelectorAll(".how-step");
  const howPhoneScreens = document.querySelectorAll(".how-screen-content");

  if (howSteps.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const stepIndex = entry.target.getAttribute("data-step");
          howSteps.forEach((s) => s.classList.remove("active"));
          entry.target.classList.add("active");

          howPhoneScreens.forEach((screen) => {
            if (screen.getAttribute("data-screen") === stepIndex) {
              screen.style.display = "block";
            } else {
              screen.style.display = "none";
            }
          });
        }
      });
    }, { threshold: 0.55 });

    howSteps.forEach((s) => observer.observe(s));
  }

  // ── 4. Hero Parallax on Giant Z & Floating Phones ────────────────────────
  const heroZ = document.querySelector(".hero-giant-z-wrap");
  const heroPrimaryPhone = document.querySelector(".phone-primary");

  if (heroZ || heroPrimaryPhone) {
    window.addEventListener("scroll", () => {
      const scrollY = window.scrollY;
      if (scrollY > 1200) return; // Stop calculating once below fold

      if (heroZ) {
        heroZ.style.transform = `translateY(${scrollY * 0.18}px)`;
      }
      if (heroPrimaryPhone) {
        heroPrimaryPhone.style.transform = `translateY(${scrollY * -0.08}px)`;
      }
    }, { passive: true });
  }

  // ── 5. Stats Number Counter Animation ────────────────────────────────────
  const statNumbers = document.querySelectorAll("[data-counter]");
  if (statNumbers.length > 0) {
    const counterObserver = new IntersectionObserver((entries, obs) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const el = entry.target;
          const target = parseInt(el.getAttribute("data-counter"), 10);
          const suffix = el.getAttribute("data-suffix") || "";
          let count = 0;
          const duration = 1600;
          const stepTime = 25;
          const increment = Math.ceil(target / (duration / stepTime));

          const timer = setInterval(() => {
            count += increment;
            if (count >= target) {
              el.textContent = target.toLocaleString() + suffix;
              clearInterval(timer);
            } else {
              el.textContent = count.toLocaleString() + suffix;
            }
          }, stepTime);

          obs.unobserve(el);
        }
      });
    }, { threshold: 0.4 });

    statNumbers.forEach((n) => counterObserver.observe(n));
  }
})();

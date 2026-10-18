/* ==========================================================================
   ZEST FORMS, CONFETTI & MODAL DIALOGS
   ========================================================================== */

(function () {
  // ── 1. Lightweight Canvas Confetti Engine ──────────────────────────────
  function fireZestConfetti(originX, originY) {
    const canvas = document.createElement("canvas");
    canvas.style.position = "fixed";
    canvas.style.top = "0";
    canvas.style.left = "0";
    canvas.style.width = "100vw";
    canvas.style.height = "100vh";
    canvas.style.pointerEvents = "none";
    canvas.style.zIndex = "999999";
    document.body.appendChild(canvas);

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    const ctx = canvas.getContext("2d");

    const colors = ["#C2FF3A", "#B8FF1A", "#141416", "#F0577A", "#F9B233", "#6CE3FF", "#FFFFFF"];
    const particles = [];
    const particleCount = 75;

    for (let i = 0; i < particleCount; i++) {
      const angle = Math.random() * Math.PI * 2;
      const velocity = 6 + Math.random() * 12;
      particles.push({
        x: originX || window.innerWidth / 2,
        y: originY || window.innerHeight / 2,
        vx: Math.cos(angle) * velocity,
        vy: Math.sin(angle) * velocity - 4,
        size: 5 + Math.random() * 7,
        color: colors[Math.floor(Math.random() * colors.length)],
        rotation: Math.random() * 360,
        rotationSpeed: (Math.random() - 0.5) * 15,
        opacity: 1,
      });
    }

    let animationFrame;
    function render() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      let aliveCount = 0;

      for (let p of particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.35; // Gravity
        p.vx *= 0.98; // Friction
        p.rotation += p.rotationSpeed;
        p.opacity -= 0.015;

        if (p.opacity > 0) {
          aliveCount++;
          ctx.save();
          ctx.translate(p.x, p.y);
          ctx.rotate((p.rotation * Math.PI) / 180);
          ctx.globalAlpha = Math.max(0, p.opacity);
          ctx.fillStyle = p.color;
          ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size);
          ctx.restore();
        }
      }

      if (aliveCount > 0) {
        animationFrame = requestAnimationFrame(render);
      } else {
        cancelAnimationFrame(animationFrame);
        canvas.remove();
      }
    }
    render();
  }

  window.fireZestConfetti = fireZestConfetti;

  // ── 2. Waitlist Form Handling ───────────────────────────────────────────
  const waitlistForms = document.querySelectorAll(".waitlist-form");
  waitlistForms.forEach((form) => {
    form.addEventListener("submit", (e) => {
      e.preventDefault();

      // Honeypot check
      const honeypot = form.querySelector("input[name='b_honey']");
      if (honeypot && honeypot.value.trim().length > 0) {
        // Bot detected — silently ignore
        return;
      }

      const emailInput = form.querySelector("input[type='email']");
      const button = form.querySelector("button[type='submit']");
      const feedback = form.querySelector(".form-feedback");

      if (!emailInput || !emailInput.value.includes("@")) {
        if (feedback) {
          feedback.textContent = "Please enter a valid student email! 🍋";
          feedback.style.color = "#F0577A";
        }
        return;
      }

      // Success
      const btnRect = button ? button.getBoundingClientRect() : null;
      const x = btnRect ? btnRect.left + btnRect.width / 2 : window.innerWidth / 2;
      const y = btnRect ? btnRect.top + btnRect.height / 2 : window.innerHeight / 2;
      fireZestConfetti(x, y);

      if (feedback) {
        feedback.innerHTML = "You're on the list! Welcome to the Zest VIP squad. 🎟️";
        feedback.style.color = "var(--color-ink)";
      }
      emailInput.value = "";
      if (button) {
        button.innerHTML = `<span>Joined! 🎉</span>`;
        button.disabled = true;
      }
    });
  });

  // ── 3. Book a Demo Modal Logic ───────────────────────────────────────────
  const modal = document.getElementById("demo-modal");
  const openButtons = document.querySelectorAll("[data-open-demo]");
  const closeButtons = document.querySelectorAll("[data-close-demo]");

  if (modal) {
    let lastActiveElement = null;

    function openModal() {
      lastActiveElement = document.activeElement;
      modal.classList.add("open");
      document.body.style.overflow = "hidden";
      const firstInput = modal.querySelector("input");
      if (firstInput) setTimeout(() => firstInput.focus(), 100);
    }

    function closeModal() {
      modal.classList.remove("open");
      document.body.style.overflow = "";
      if (lastActiveElement) lastActiveElement.focus();
    }

    openButtons.forEach((btn) => btn.addEventListener("click", openModal));
    closeButtons.forEach((btn) => btn.addEventListener("click", closeModal));

    // Close on backdrop click
    modal.addEventListener("click", (e) => {
      if (e.target === modal) closeModal();
    });

    // Close on Escape key + Trap Tab Focus
    window.addEventListener("keydown", (e) => {
      if (!modal.classList.contains("open")) return;
      if (e.key === "Escape") {
        closeModal();
      } else if (e.key === "Tab") {
        const focusables = modal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
        if (focusables.length === 0) return;
        const first = focusables[0];
        const last = focusables[focusables.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          last.focus();
          e.preventDefault();
        } else if (!e.shiftKey && document.activeElement === last) {
          first.focus();
          e.preventDefault();
        }
      }
    });

    const demoForm = document.getElementById("demo-form");
    if (demoForm) {
      demoForm.addEventListener("submit", (e) => {
        e.preventDefault();
        const submitBtn = demoForm.querySelector("button[type='submit']");
        if (submitBtn) {
          submitBtn.textContent = "Demo Request Sent! 🍋";
          submitBtn.disabled = true;
        }
        setTimeout(() => {
          closeModal();
          if (submitBtn) {
            submitBtn.textContent = "Submit Request";
            submitBtn.disabled = false;
          }
          demoForm.reset();
        }, 1500);
      });
    }
  }

  // ── 4. Copy-to-Clipboard Share Button ────────────────────────────────────
  const copyButtons = document.querySelectorAll("[data-copy-link]");
  copyButtons.forEach((btn) => {
    btn.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(window.location.href);
        const originalText = btn.innerHTML;
        btn.innerHTML = `<span>Copied! ⚡</span>`;
        setTimeout(() => {
          btn.innerHTML = originalText;
        }, 2000);
      } catch (err) {
        console.error("Clipboard write failed", err);
      }
    });
  });
})();

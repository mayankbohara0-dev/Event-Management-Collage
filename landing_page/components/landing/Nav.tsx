"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence, useScroll } from "framer-motion";
import { Menu, X, ArrowUpRight } from "lucide-react";
import BlobLogo from "@/components/brand/BlobLogo";
import MagneticButton from "@/components/brand/MagneticButton";
import { landingData } from "@/lib/landing-data";

export default function Nav() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState<string>("");
  const { scrollYProgress } = useScroll();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 24);

      // Determine active section for nav indicator
      const sections = ["how-it-works", "features", "organizers", "faq"];
      const scrollPos = window.scrollY + 180;

      for (const sectionId of sections) {
        const el = document.getElementById(sectionId);
        if (el) {
          const top = el.offsetTop;
          const height = el.offsetHeight;
          if (scrollPos >= top && scrollPos < top + height) {
            setActiveSection(sectionId);
            return;
          }
        }
      }
      if (window.scrollY < 300) {
        setActiveSection("");
      }
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    handleScroll();
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const nav = landingData.navigation;

  return (
    <>
      {/* Scroll progress bar */}
      <motion.div
        className="fixed top-0 left-0 right-0 h-[2.5px] bg-gradient-to-r from-[var(--sky)] via-[var(--core)] to-[var(--blue)] z-50 origin-left"
        style={{ scaleX: scrollYProgress }}
      />

      <header
        className={`fixed top-0 left-0 right-0 z-40 transition-all duration-300 ${
          scrolled
            ? "bg-white/85 backdrop-blur-md border-b border-[var(--line)] shadow-[0_4px_20px_rgba(11,18,32,0.04)] h-[60px]"
            : "bg-transparent h-[76px]"
        }`}
      >
        <div className="max-w-[1200px] mx-auto h-full px-6 flex items-center justify-between">
          {/* Left: Logo + wordmark */}
          <a
            href="#"
            className="flex items-center gap-2.5 text-[var(--ink)] no-underline group select-none"
            aria-label="ZEST Home"
          >
            <BlobLogo size={32} animateOnLoad />
            <span className="font-semibold text-[22px] tracking-tight lowercase text-[var(--ink)] group-hover:text-[var(--blue)] transition-colors">
              {nav.brandName}
            </span>
          </a>

          {/* Center: Desktop links with animated active indicator */}
          <nav className="hidden md:flex items-center gap-1 bg-white/70 backdrop-blur-sm p-1.5 rounded-full border border-[var(--line)]">
            {nav.links.map((link) => {
              const sectionId = link.href.replace("#", "");
              const isActive = activeSection === sectionId;
              return (
                <a
                  key={link.label}
                  href={link.href}
                  className={`relative px-4 py-1.5 text-[14px] font-medium transition-colors rounded-full ${
                    isActive ? "text-[var(--blue)]" : "text-[var(--ink-2)] hover:text-[var(--ink)]"
                  }`}
                >
                  {link.label}
                  {isActive && (
                    <motion.div
                      layoutId="navIndicator"
                      className="absolute inset-0 bg-[var(--sky)]/15 rounded-full -z-10"
                      transition={{ type: "spring", stiffness: 380, damping: 30 }}
                    />
                  )}
                </a>
              );
            })}
          </nav>

          {/* Right: CTAs */}
          <div className="hidden sm:flex items-center gap-3">
            <MagneticButton
              variant="secondary"
              href={nav.ctaSecondary.href}
              className="py-2 px-5 text-[14px]"
            >
              {nav.ctaSecondary.label}
            </MagneticButton>
            <MagneticButton
              variant="primary"
              href={nav.ctaPrimary.href}
              className="py-2 px-5 text-[14px]"
            >
              {nav.ctaPrimary.label}
            </MagneticButton>
          </div>

          {/* Mobile hamburger button */}
          <div className="flex sm:hidden items-center gap-2">
            <MagneticButton
              variant="primary"
              href={nav.ctaPrimary.href}
              className="py-1.5 px-3.5 text-[13px]"
            >
              Get app
            </MagneticButton>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-full border border-[var(--line)] bg-white text-[var(--ink)] focus:outline-none focus:ring-2 focus:ring-[var(--blue)]"
              aria-label={mobileMenuOpen ? "Close menu" : "Open menu"}
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>
      </header>

      {/* Full-screen Mobile Sheet */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.25 }}
            className="fixed inset-0 top-[60px] bg-white z-40 p-6 flex flex-col justify-between overflow-y-auto sm:hidden"
          >
            <div className="flex flex-col gap-4 pt-6">
              {nav.links.map((link, idx) => (
                <motion.a
                  key={link.label}
                  href={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  initial={{ opacity: 0, x: -16 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: idx * 0.06 }}
                  className="text-[24px] font-semibold text-[var(--ink)] hover:text-[var(--blue)] py-2 border-b border-[var(--line)]/60 flex items-center justify-between"
                >
                  {link.label}
                  <ArrowUpRight size={20} className="text-[var(--ink-3)]" />
                </motion.a>
              ))}
            </div>

            <div className="flex flex-col gap-3 pb-8 pt-6">
              <MagneticButton
                variant="secondary"
                href={nav.ctaSecondary.href}
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center"
              >
                {nav.ctaSecondary.label}
              </MagneticButton>
              <MagneticButton
                variant="primary"
                href={nav.ctaPrimary.href}
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center"
              >
                {nav.ctaPrimary.label}
              </MagneticButton>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}

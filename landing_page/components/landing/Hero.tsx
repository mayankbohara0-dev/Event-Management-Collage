"use client";

import React, { useRef } from "react";
import { motion, useMotionValue, useTransform, useReducedMotion } from "framer-motion";
import { Sparkles, Calendar, MapPin, CheckCircle2, ChevronRight, Zap } from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import MagneticButton from "@/components/brand/MagneticButton";
import MeshCard from "@/components/brand/MeshCard";
import Mascot from "@/components/brand/Mascot";
import { landingData } from "@/lib/landing-data";
import { easeOutExpo } from "@/lib/motion";

export default function Hero() {
  const heroData = landingData.hero;
  const reducedMotion = useReducedMotion();

  // Mouse Parallax for hero card
  const cardRef = useRef<HTMLDivElement>(null);
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  // Card layers move at different depths (±10px)
  const rotateX = useTransform(mouseY, [-300, 300], [5, -5]);
  const rotateY = useTransform(mouseX, [-300, 300], [-5, 5]);
  const chip1Y = useTransform(mouseY, [-300, 300], [-10, 10]);
  const chip2Y = useTransform(mouseY, [-300, 300], [12, -12]);
  const chip3Y = useTransform(mouseY, [-300, 300], [-8, 8]);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (reducedMotion || !cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    mouseX.set(e.clientX - centerX);
    mouseY.set(e.clientY - centerY);
  };

  const handleMouseLeave = () => {
    mouseX.set(0);
    mouseY.set(0);
  };

  return (
    <section className="relative pt-[100px] pb-[60px] sm:pt-[120px] sm:pb-[72px] lg:pt-[150px] lg:pb-[110px] overflow-hidden">
      {/* Background radial glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bg-gradient-to-tr from-[var(--sky)]/15 via-[var(--core)]/10 to-transparent blur-[120px] pointer-events-none -z-10" />

      <div className="max-w-[1200px] mx-auto px-5 sm:px-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-8 items-center">
          {/* Left Column: Headline & CTAs */}
          <div className="lg:col-span-7 flex flex-col items-start text-left">
            <SectionHeading
              align="left"
              level="h1"
              eyebrow={heroData.eyebrow}
              headingParts={heroData.headingParts}
              subtitle={heroData.subtitle}
              className="max-w-none"
            />

            {/* CTAs */}
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 sm:gap-4 mt-6 sm:mt-8 w-full sm:w-auto">
              <MagneticButton variant="primary" href={heroData.ctaPrimary.href} className="w-full sm:w-auto text-center">
                {heroData.ctaPrimary.label}
              </MagneticButton>
              <MagneticButton variant="secondary" href={heroData.ctaSecondary.href} className="w-full sm:w-auto text-center">
                {heroData.ctaSecondary.label}
              </MagneticButton>
            </div>

            {/* Micro-line */}
            <p className="text-[12px] sm:text-[13px] text-[var(--ink-3)] font-medium mt-3.5 sm:mt-4 tracking-wide">
              {heroData.microcopy}
            </p>
          </div>

          {/* Right Column: Sky Mesh Card with CSS Phone & Floating Chips */}
          <div
            ref={cardRef}
            onMouseMove={handleMouseMove}
            onMouseLeave={handleMouseLeave}
            className="lg:col-span-5 relative flex justify-center perspective-[1200px] mt-4 lg:mt-0"
          >
            {/* Mascot peeking over card top-right */}
            <motion.div
              className="absolute -top-10 sm:-top-12 right-2 sm:right-6 z-20 pointer-events-auto"
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.5, duration: 0.6, ease: easeOutExpo }}
            >
              <Mascot size={75} tint="lemon" />
            </motion.div>

            {/* Main Sky Mesh Card (Designjoy style) */}
            <motion.div
              style={{
                rotateX: reducedMotion ? 0 : rotateX,
                rotateY: reducedMotion ? 0 : rotateY,
                transformStyle: "preserve-3d",
              }}
              transition={{ type: "spring", stiffness: 300, damping: 30 }}
              className="w-full max-w-[430px]"
            >
              <MeshCard recipe="sky" className="p-5 sm:p-7 shadow-[0_20px_60px_rgba(0,99,240,0.22)]">
                {/* CSS-built phone showing ZEST home feed */}
                <motion.div
                  initial={{ y: 40, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ duration: 0.7, ease: easeOutExpo }}
                  className="w-full bg-[#FFFFFF] rounded-[28px] p-4 text-[var(--ink)] shadow-[0_15px_35px_rgba(0,0,0,0.18)] border border-white/60 relative overflow-hidden"
                >
                  {/* Phone Speaker notch bar */}
                  <div className="w-20 h-1 bg-gray-200 rounded-full mx-auto mb-3" />

                  {/* Campus XP Banner Card inside phone */}
                  <div className="bg-gradient-to-r from-[var(--core)] to-[var(--blue)] rounded-[18px] p-3.5 text-white mb-3 shadow-[0_6px_20px_rgba(10,165,240,0.3)]">
                    <div className="flex items-center justify-between text-xs mb-1.5 opacity-90 font-medium">
                      <span>Level {heroData.mockPhone.user.level} · Campus Explorer</span>
                      <span className="flex items-center gap-1 font-semibold text-[#FFD84D]">
                        <Zap size={13} fill="#FFD84D" /> {heroData.mockPhone.user.xp} XP
                      </span>
                    </div>
                    {/* XP Progress Bar */}
                    <div className="w-full h-1.5 bg-white/20 rounded-full overflow-hidden">
                      <div className="h-full bg-gradient-to-r from-[#6CE3FF] to-[#FFD84D] w-[71%] rounded-full" />
                    </div>
                    <div className="text-[10px] text-white/70 mt-1 flex justify-between">
                      <span>Batch '26</span>
                      <span>580 XP to Level 5</span>
                    </div>
                  </div>

                  {/* Search & Category Chips */}
                  <div className="flex gap-1.5 overflow-x-auto pb-2 scrollbar-none text-[11px] font-semibold text-[var(--ink-2)]">
                    {heroData.mockPhone.chips.map((chip, i) => (
                      <span
                        key={chip}
                        className={`px-2.5 py-1 rounded-full whitespace-nowrap cursor-pointer transition-colors ${
                          i === 0
                            ? "bg-[var(--blue)] text-white"
                            : "bg-[#F1F5F9] text-[var(--ink-2)] hover:bg-[#E2E8F0]"
                        }`}
                      >
                        {chip}
                      </span>
                    ))}
                  </div>

                  {/* Featured Event Row with "Going ✓" */}
                  <div className="mt-2 bg-[#F8FAFC] border border-[var(--line)] rounded-[16px] p-3 hover:border-[var(--sky)] transition-colors">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] uppercase font-bold text-[var(--core)] tracking-wider">
                        {heroData.mockPhone.featuredEvent.club}
                      </span>
                      <span className="text-[10px] font-semibold text-[#10B981] bg-[#ECFDF5] px-2 py-0.5 rounded-full flex items-center gap-1">
                        <CheckCircle2 size={10} /> {heroData.mockPhone.featuredEvent.status}
                      </span>
                    </div>
                    <h4 className="font-semibold text-[13px] text-[var(--ink)] mt-1 line-clamp-1">
                      {heroData.mockPhone.featuredEvent.title}
                    </h4>
                    <div className="flex items-center gap-3 text-[10px] text-[var(--ink-3)] mt-2">
                      <span className="flex items-center gap-1">
                        <Calendar size={10} /> {heroData.mockPhone.featuredEvent.date}
                      </span>
                      <span className="flex items-center gap-1">
                        <MapPin size={10} /> {heroData.mockPhone.featuredEvent.venue}
                      </span>
                    </div>
                    {/* Seats Left Bar */}
                    <div className="mt-2.5 pt-2 border-t border-[var(--line)] flex items-center justify-between text-[10px]">
                      <span className="text-[var(--coral)] font-semibold flex items-center gap-1">
                        ⚡ {heroData.mockPhone.featuredEvent.seatsLeft} seats left
                      </span>
                      <span className="text-[var(--core)] font-semibold">
                        +{heroData.mockPhone.featuredEvent.xpReward} XP
                      </span>
                    </div>
                  </div>

                  {/* Secondary Event Row preview */}
                  <div className="mt-2 bg-[#F8FAFC] border border-[var(--line)] rounded-[16px] p-2.5 flex items-center justify-between">
                    <div>
                      <span className="text-[9px] font-bold text-[var(--ink-3)] uppercase">
                        {heroData.mockPhone.secondaryEvent.club}
                      </span>
                      <p className="text-[11px] font-medium text-[var(--ink)] line-clamp-1">
                        {heroData.mockPhone.secondaryEvent.title}
                      </p>
                    </div>
                    <span className="text-[10px] font-semibold text-[var(--blue)] bg-[var(--sky)]/15 px-2 py-0.5 rounded-full">
                      {heroData.mockPhone.secondaryEvent.status}
                    </span>
                  </div>
                </motion.div>
              </MeshCard>
            </motion.div>

            {/* Floating Glass Chips bobbing out of phase */}
            {/* Chip 1: Pass verified ✓ */}
            <motion.div
              style={{ y: reducedMotion ? 0 : chip1Y }}
              animate={
                reducedMotion
                  ? undefined
                  : {
                      y: [-4, 6, -4],
                      transition: { duration: 4.2, repeat: Infinity, ease: "easeInOut" },
                    }
              }
              className="absolute left-1 sm:-left-6 top-10 sm:top-16 z-30 bg-white/95 backdrop-blur-md px-2.5 sm:px-3.5 py-1.5 sm:py-2 rounded-full border border-white/80 shadow-[0_8px_24px_rgba(11,18,32,0.1)] flex items-center gap-1.5 sm:gap-2 text-[11px] sm:text-[12px] font-semibold text-[var(--ink)]"
            >
              <span className="w-4 h-4 sm:w-5 sm:h-5 rounded-full bg-[#ECFDF5] text-[#10B981] flex items-center justify-center">
                <CheckCircle2 size={11} />
              </span>
              <span>Pass verified ✓</span>
            </motion.div>

            {/* Chip 2: +80 XP */}
            <motion.div
              style={{ y: reducedMotion ? 0 : chip2Y }}
              animate={
                reducedMotion
                  ? undefined
                  : {
                      y: [6, -6, 6],
                      transition: { duration: 3.6, repeat: Infinity, ease: "easeInOut", delay: 0.4 },
                    }
              }
              className="absolute right-1 sm:-right-6 bottom-16 sm:bottom-20 z-30 bg-white/95 backdrop-blur-md px-2.5 sm:px-3.5 py-1.5 sm:py-2 rounded-full border border-white/80 shadow-[0_8px_24px_rgba(11,18,32,0.1)] flex items-center gap-1.5 sm:gap-2 text-[11px] sm:text-[12px] font-semibold text-[var(--ink)]"
            >
              <span className="w-4 h-4 sm:w-5 sm:h-5 rounded-full bg-[#FEF3C7] text-[#D97706] flex items-center justify-center">
                <Sparkles size={11} />
              </span>
              <span className="text-[#0AA5F0] font-bold">+80 XP</span>
            </motion.div>

            {/* Chip 3: 5 spots left ⚡ */}
            <motion.div
              style={{ y: reducedMotion ? 0 : chip3Y }}
              animate={
                reducedMotion
                  ? undefined
                  : {
                      y: [-5, 5, -5],
                      transition: { duration: 4.8, repeat: Infinity, ease: "easeInOut", delay: 0.8 },
                    }
              }
              className="absolute left-2 sm:left-4 -bottom-3 sm:-bottom-4 z-30 bg-white/95 backdrop-blur-md px-2.5 sm:px-3.5 py-1 sm:py-1.5 rounded-full border border-white/80 shadow-[0_8px_24px_rgba(11,18,32,0.1)] flex items-center gap-1 sm:gap-1.5 text-[10px] sm:text-[11px] font-semibold text-[var(--coral)]"
            >
              <Zap size={11} className="fill-[var(--coral)]" />
              <span>5 spots left ⚡</span>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  );
}

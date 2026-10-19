"use client";

import React, { useState } from "react";
import { motion, AnimatePresence, useReducedMotion } from "framer-motion";
import { Calendar as CalendarIcon, Clock, MapPin, Sparkles } from "lucide-react";
import MagneticButton from "@/components/brand/MagneticButton";
import Mascot, { MascotTint } from "@/components/brand/Mascot";
import { landingData } from "@/lib/landing-data";

export default function FinalCTA() {
  const { headingParts, subtitle, ctaPrimary, ctaSecondary, calendarWidget } =
    landingData.finalCta;
  const [selectedDay, setSelectedDay] = useState<number | null>(22);
  const reducedMotion = useReducedMotion();

  // 7 colored mascot blobs: blue, lemon, coral, lavender, mint, aqua, blue
  const mascotTints: MascotTint[] = [
    "blue",
    "lemon",
    "coral",
    "lavender",
    "mint",
    "aqua",
    "blue",
  ];

  // Calendar dates setup (31 days in October)
  const daysInMonth = Array.from({ length: 31 }, (_, i) => i + 1);
  const activeEvent = calendarWidget.events.find((e) => e.day === selectedDay);

  return (
    <section id="contact" className="bg-[var(--ink)] text-white pt-[70px] lg:pt-[90px] pb-12 sm:pb-16 relative overflow-hidden">
      {/* Background radial ambient lights */}
      <div className="absolute top-1/3 left-1/4 w-[600px] h-[400px] bg-[var(--core)]/10 blur-[130px] rounded-full pointer-events-none" />
      <div className="absolute bottom-10 right-1/4 w-[500px] h-[350px] bg-[var(--sky)]/10 blur-[120px] rounded-full pointer-events-none" />

      <div className="max-w-[1200px] mx-auto px-5 sm:px-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-12 items-center">
          {/* Left Column: Heading & CTAs */}
          <div className="lg:col-span-6 text-left">
            <h2 className="heading-h2 text-white">
              {headingParts.prefix}
              <span className="serif-accent text-[var(--sky)] font-serif italic">
                {headingParts.accent}
              </span>
              {headingParts.suffix}
            </h2>

            <p className="body-lead text-gray-300 mt-4 sm:mt-6 max-w-[500px]">
              {subtitle}
            </p>

            <div className="flex flex-col sm:flex-row flex-wrap items-start sm:items-center gap-3 sm:gap-4 mt-6 sm:mt-8">
              <MagneticButton variant="primary" href={ctaPrimary.href} className="w-full sm:w-auto text-center">
                {ctaPrimary.label}
              </MagneticButton>
              <MagneticButton
                variant="secondary"
                href={ctaSecondary.href}
                className="w-full sm:w-auto text-center bg-white/10 text-white border-white/20 hover:bg-white/15"
              >
                {ctaSecondary.label}
              </MagneticButton>
            </div>
          </div>

          {/* Right Column: Event Calendar Card */}
          <div className="lg:col-span-6 flex justify-center">
            <div className="w-full max-w-[420px] rounded-[32px] bg-[#152238] border border-gray-700/60 p-6 shadow-[0_20px_50px_rgba(0,0,0,0.4)] relative">
              {/* Calendar Header */}
              <div className="flex items-center justify-between pb-4 border-b border-gray-700/60">
                <div className="flex items-center gap-2">
                  <CalendarIcon size={18} className="text-[var(--sky)]" />
                  <span className="text-[15px] font-bold text-white">
                    {calendarWidget.month}
                  </span>
                </div>
                <span className="text-[11px] font-semibold text-[var(--sky)] bg-[var(--sky)]/15 px-2.5 py-0.5 rounded-full">
                  Campus Schedule
                </span>
              </div>

              {/* Day headers */}
              <div className="grid grid-cols-7 gap-1 mt-4 text-center text-[11px] font-bold text-gray-400">
                {["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].map((d) => (
                  <span key={d}>{d}</span>
                ))}
              </div>

              {/* Month Grid */}
              <div className="grid grid-cols-7 gap-1.5 mt-2">
                {daysInMonth.map((day) => {
                  const hasEvent = calendarWidget.events.some((e) => e.day === day);
                  const isSelected = selectedDay === day;

                  return (
                    <button
                      key={day}
                      onClick={() => hasEvent && setSelectedDay(day)}
                      disabled={!hasEvent}
                      className={`h-9 rounded-[12px] flex flex-col items-center justify-center text-[12px] font-medium transition-all relative ${
                        isSelected
                          ? "bg-[var(--blue)] text-white font-bold ring-2 ring-[var(--sky)] shadow-md"
                          : hasEvent
                          ? "bg-gray-800 text-white hover:bg-gray-700 cursor-pointer"
                          : "text-gray-400 cursor-default opacity-60"
                      }`}
                    >
                      <span>{day}</span>
                      {hasEvent && (
                        <span
                          className={`w-1.5 h-1.5 rounded-full mt-0.5 ${
                            isSelected ? "bg-[#FFD84D]" : "bg-[var(--sky)]"
                          }`}
                        />
                      )}
                    </button>
                  );
                })}
              </div>

              {/* Tiny Popover Event details when date is clicked */}
              <AnimatePresence mode="wait">
                {activeEvent && (
                  <motion.div
                    key={activeEvent.day}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: 10 }}
                    transition={{ duration: 0.2 }}
                    className="mt-4 pt-4 border-t border-gray-700/60 bg-gray-900/60 rounded-[18px] p-3 border border-gray-700/40"
                  >
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="text-[var(--sky)] font-bold uppercase tracking-wider">
                        {activeEvent.category} · Oct {activeEvent.day}
                      </span>
                      <span className="text-[#FFD84D] font-bold flex items-center gap-1">
                        <Sparkles size={11} /> +{activeEvent.xp} XP
                      </span>
                    </div>
                    <h4 className="text-[13px] font-bold text-white mt-1">
                      {activeEvent.title}
                    </h4>
                    <div className="flex items-center gap-4 text-[11px] text-gray-300 mt-2">
                      <span className="flex items-center gap-1">
                        <Clock size={11} className="text-[var(--sky)]" /> {activeEvent.time}
                      </span>
                      <span className="flex items-center gap-1">
                        <MapPin size={11} className="text-[var(--coral)]" /> {activeEvent.venue}
                      </span>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>

        {/* Bottom: Pile of 7 coloured Mascot blobs that drop in with spring physics */}
        <div className="mt-14 sm:mt-20 pt-8 sm:pt-10 border-t border-gray-800/80">
          <p className="text-center text-[12px] font-bold tracking-widest text-gray-400 uppercase mb-6 sm:mb-8">
            MEET THE ZEST MASCOT CREW
          </p>

          <div className="flex flex-wrap items-end justify-center gap-2 sm:gap-6 pb-2">
            {mascotTints.map((tint, i) => (
              <motion.div
                key={`${tint}-${i}`}
                initial={reducedMotion ? {} : { y: -80, opacity: 0 }}
                whileInView={reducedMotion ? {} : { y: 0, opacity: 1 }}
                viewport={{ once: true }}
                transition={
                  reducedMotion
                    ? {}
                    : {
                        type: "spring",
                        stiffness: 220,
                        damping: 14,
                        delay: i * 0.08,
                      }
                }
                whileHover={
                  reducedMotion
                    ? {}
                    : {
                        y: -18,
                        scale: 1.15,
                        transition: { type: "spring", stiffness: 400, damping: 15 },
                      }
                }
                className="cursor-pointer"
              >
                <div className="sm:hidden">
                  <Mascot size={i === 3 ? 75 : 60} tint={tint} />
                </div>
                <div className="hidden sm:block">
                  <Mascot size={i === 3 ? 100 : 80} tint={tint} />
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

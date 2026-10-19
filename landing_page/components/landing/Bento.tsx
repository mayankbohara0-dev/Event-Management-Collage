"use client";

import React, { useState } from "react";
import { motion, useReducedMotion } from "framer-motion";
import {
  Sparkles,
  BarChart3,
  PlusCircle,
  Sliders,
  ScanLine,
  Users,
  Download,
  CheckCircle2,
  ShieldAlert,
  Zap,
  ArrowRight,
  Check,
} from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import MagneticButton from "@/components/brand/MagneticButton";
import Mascot from "@/components/brand/Mascot";
import { landingData } from "@/lib/landing-data";

const ORGANIZER_ICONS: Record<string, React.ElementType> = {
  BarChart3,
  PlusCircle,
  Sliders,
  ScanLine,
  Users,
  Download,
  CheckCircle2,
  ShieldAlert,
  Zap,
};

export default function Bento() {
  const { bento } = landingData;
  const [studentHovered, setStudentHovered] = useState(false);
  const [organizerHovered, setOrganizerHovered] = useState(false);
  const reducedMotion = useReducedMotion();

  return (
    <section id="organizers" className="py-[60px] lg:py-[120px] relative">
      <div className="max-w-[1200px] mx-auto px-5 sm:px-6">
        <SectionHeading
          align="center"
          headingParts={bento.headingParts}
          subtitle={bento.subtitle}
          className="mb-10 sm:mb-14"
        />

        {/* Two big white cards side by side */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8">
          {/* 1. FOR STUDENTS CARD */}
          <motion.div
            initial={{ opacity: 0, y: 28 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            onMouseEnter={() => setStudentHovered(true)}
            onMouseLeave={() => setStudentHovered(false)}
            className="card-soft p-6 sm:p-10 flex flex-col justify-between overflow-hidden relative group"
          >
            {/* Top info */}
            <div>
              <div className="inline-flex items-center gap-2 mb-3">
                <span className="w-2 h-2 rounded-full bg-[var(--sky)]" />
                <span className="eyebrow">{bento.students.title}</span>
              </div>
              <h3 className="text-[22px] sm:text-[30px] font-semibold text-[var(--ink)] tracking-tight">
                Campus life in your pocket
              </h3>
              <p className="body-base text-[var(--ink-2)] mt-2">
                {bento.students.tagline}
              </p>
            </div>

            {/* Interactive Graphic: Three tilted CSS phone screens that fan out on hover */}
            <div className="py-8 sm:py-12 relative h-[250px] sm:h-[280px] flex items-center justify-center select-none perspective-[1000px] overflow-hidden">
              {/* Phone 1: Left (Home) */}
              <motion.div
                animate={
                  reducedMotion
                    ? {}
                    : studentHovered
                    ? { x: -65, rotateZ: -12, y: 8, scale: 0.92 }
                    : { x: -30, rotateZ: -6, y: 0, scale: 0.92 }
                }
                transition={{ type: "spring", stiffness: 260, damping: 22 }}
                className="absolute w-[140px] sm:w-[160px] h-[195px] sm:h-[210px] bg-white rounded-[20px] sm:rounded-[22px] border border-[var(--line)] shadow-[0_12px_30px_rgba(11,18,32,0.12)] p-3 flex flex-col justify-between -z-10"
              >
                <div>
                  <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mb-2" />
                  <span className="text-[9px] font-bold text-[var(--core)] uppercase tracking-wider">
                    Feed
                  </span>
                  <div className="mt-2 space-y-1.5">
                    <div className="w-full h-8 bg-[#F1F5F9] rounded-[8px]" />
                    <div className="w-full h-8 bg-[#F1F5F9] rounded-[8px]" />
                  </div>
                </div>
                <span className="text-[9px] font-semibold text-[var(--ink-3)] text-center">
                  Home Feed
                </span>
              </motion.div>

              {/* Phone 2: Center (My Passes) */}
              <motion.div
                animate={
                  reducedMotion
                    ? {}
                    : studentHovered
                    ? { y: -12, scale: 1.03 }
                    : { y: 0, scale: 1 }
                }
                transition={{ type: "spring", stiffness: 260, damping: 22 }}
                className="relative z-10 w-[150px] sm:w-[170px] h-[210px] sm:h-[225px] bg-gradient-to-br from-[var(--sky)] to-[var(--blue)] rounded-[22px] sm:rounded-[24px] p-3 sm:p-3.5 text-white shadow-[0_16px_40px_rgba(0,99,240,0.3)] flex flex-col justify-between border border-white/40"
              >
                <div>
                  <div className="w-10 h-1 bg-white/40 rounded-full mx-auto mb-2" />
                  <div className="flex justify-between items-center text-[10px] font-bold">
                    <span>MY PASS</span>
                    <span className="bg-white/20 px-1.5 py-0.5 rounded-full">+80 XP</span>
                  </div>
                  {/* QR Box */}
                  <div className="w-16 h-16 sm:w-20 sm:h-20 bg-white rounded-[12px] sm:rounded-[14px] mx-auto mt-2 sm:mt-3 p-1.5 flex items-center justify-center">
                    <div className="w-full h-full bg-[var(--ink)] rounded-[8px] flex items-center justify-center text-white text-[9px] font-mono">
                      QR PASS
                    </div>
                  </div>
                </div>
                <div className="text-[10px] text-center font-medium bg-white/20 py-0.5 sm:py-1 rounded-full">
                  Gate Ready
                </div>
              </motion.div>

              {/* Phone 3: Right (Leaderboard) */}
              <motion.div
                animate={
                  reducedMotion
                    ? {}
                    : studentHovered
                    ? { x: 65, rotateZ: 12, y: 8, scale: 0.92 }
                    : { x: 30, rotateZ: 6, y: 0, scale: 0.92 }
                }
                transition={{ type: "spring", stiffness: 260, damping: 22 }}
                className="absolute w-[140px] sm:w-[160px] h-[195px] sm:h-[210px] bg-white rounded-[20px] sm:rounded-[22px] border border-[var(--line)] shadow-[0_12px_30px_rgba(11,18,32,0.12)] p-3 flex flex-col justify-between -z-10"
              >
                <div>
                  <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mb-2" />
                  <span className="text-[9px] font-bold text-[#F59E0B] uppercase tracking-wider">
                    Leaderboard
                  </span>
                  <div className="mt-2 space-y-1.5">
                    <div className="w-full h-4 bg-[#FEF3C7] rounded-[6px]" />
                    <div className="w-full h-4 bg-[#F1F5F9] rounded-[6px]" />
                    <div className="w-full h-4 bg-[#F1F5F9] rounded-[6px]" />
                  </div>
                </div>
                <span className="text-[9px] font-semibold text-[var(--ink-3)] text-center">
                  Campus XP
                </span>
              </motion.div>
            </div>

            {/* Checklist & Button */}
            <div className="pt-4 border-t border-[var(--line)]">
              <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 mb-6 text-[13px] text-[var(--ink-2)]">
                {bento.students.features.map((feat) => (
                  <li key={feat} className="flex items-center gap-2">
                    <span className="w-4 h-4 rounded-full bg-[#ECFDF5] text-[#10B981] flex items-center justify-center flex-shrink-0">
                      <Check size={11} strokeWidth={3} />
                    </span>
                    <span>{feat}</span>
                  </li>
                ))}
              </ul>
              <MagneticButton variant="secondary" href="#get-app" className="w-full sm:w-auto text-center">
                {bento.students.cta}
              </MagneticButton>
            </div>
          </motion.div>

          {/* 2. FOR ORGANIZERS CARD */}
          <motion.div
            initial={{ opacity: 0, y: 28 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.1 }}
            onMouseEnter={() => setOrganizerHovered(true)}
            onMouseLeave={() => setOrganizerHovered(false)}
            className="card-soft p-6 sm:p-10 flex flex-col justify-between overflow-hidden relative group"
          >
            {/* Mascot peeking in from top-right corner */}
            <div className="absolute -top-4 -right-4 sm:-top-6 sm:-right-6 z-20 pointer-events-auto">
              <Mascot size={60} tint="aqua" />
            </div>

            {/* Top info */}
            <div>
              <div className="inline-flex items-center gap-2 mb-3">
                <span className="w-2 h-2 rounded-full bg-[var(--core)]" />
                <span className="eyebrow">{bento.organizers.title}</span>
              </div>
              <h3 className="text-[22px] sm:text-[30px] font-semibold text-[var(--ink)] tracking-tight">
                The control room for campus clubs
              </h3>
              <p className="body-base text-[var(--ink-2)] mt-2">
                {bento.organizers.tagline}
              </p>
            </div>

            {/* Interactive Graphic: Floating pill cloud that bobs and rearranges */}
            <div className="py-6 sm:py-8 relative min-h-[240px] sm:h-[280px] flex items-center justify-center">
              <div className="flex flex-wrap justify-center gap-2 sm:gap-2.5 max-w-[420px]">
                {bento.organizers.pills.map((pill, i) => {
                  const Icon = ORGANIZER_ICONS[pill.icon] || Zap;
                  const offsets = [
                    { x: -8, y: -4 },
                    { x: 10, y: 5 },
                    { x: -5, y: 8 },
                    { x: 8, y: -6 },
                    { x: -12, y: 3 },
                    { x: 6, y: -8 },
                    { x: -4, y: 6 },
                    { x: 10, y: -3 },
                    { x: -6, y: 4 },
                  ];
                  const offset = offsets[i % offsets.length];

                  return (
                    <motion.div
                      key={pill.label}
                      animate={
                        reducedMotion
                          ? {}
                          : organizerHovered
                          ? {
                              x: offset.x * 1.5,
                              y: offset.y * 1.5,
                              scale: 1.04,
                            }
                          : {
                              x: [0, offset.x, 0],
                              y: [0, offset.y, 0],
                              transition: {
                                duration: 3.5 + (i % 3),
                                repeat: Infinity,
                                ease: "easeInOut",
                              },
                            }
                      }
                      className="px-3 sm:px-3.5 py-1.5 sm:py-2 rounded-full bg-[#F8FAFC] border border-[var(--line)] shadow-sm flex items-center gap-1.5 sm:gap-2 text-[11px] sm:text-[12px] font-semibold text-[var(--ink)] hover:border-[var(--core)] hover:bg-white transition-colors cursor-default"
                    >
                      <Icon size={13} className="text-[var(--core)] sm:w-3.5 sm:h-3.5" />
                      <span>{pill.label}</span>
                    </motion.div>
                  );
                })}
              </div>
            </div>

            {/* Checklist & Button */}
            <div className="pt-4 border-t border-[var(--line)]">
              <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 mb-6 text-[13px] text-[var(--ink-2)]">
                {bento.organizers.features.map((feat) => (
                  <li key={feat} className="flex items-center gap-2">
                    <span className="w-4 h-4 rounded-full bg-[#EFF6FF] text-[var(--blue)] flex items-center justify-center flex-shrink-0">
                      <Check size={11} strokeWidth={3} />
                    </span>
                    <span>{feat}</span>
                  </li>
                ))}
              </ul>
              <MagneticButton variant="primary" href="#contact" className="w-full sm:w-auto text-center">
                {bento.organizers.cta}
              </MagneticButton>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}

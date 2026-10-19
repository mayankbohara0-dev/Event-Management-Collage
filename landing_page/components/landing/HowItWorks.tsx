"use client";

import React, { useState, useEffect, useRef } from "react";
import { motion, useInView, useReducedMotion } from "framer-motion";
import { QrCode, Check, Sparkles } from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import MeshCard from "@/components/brand/MeshCard";
import {
  landingData,
  DiscoverCardData,
  RegisterCardData,
  GetInCardData,
} from "@/lib/landing-data";

export default function HowItWorks() {
  const data = landingData.howItWorks;
  const [discoverCard, registerCard, getInCard] = data.cards as [
    DiscoverCardData,
    RegisterCardData,
    GetInCardData
  ];

  const reducedMotion = useReducedMotion();
  const sectionRef = useRef<HTMLDivElement>(null);
  const isInView = useInView(sectionRef, { margin: "-80px 0px" });

  // Card 2: Register typing / autofill loop
  const [typedFields, setTypedFields] = useState<number>(0);
  const [isRegistered, setIsRegistered] = useState(false);

  useEffect(() => {
    if (!isInView || reducedMotion) return;

    let step = 0;
    const interval = setInterval(() => {
      step = (step + 1) % 5;
      if (step <= 3) {
        setTypedFields(step);
        setIsRegistered(false);
      } else if (step === 4) {
        setIsRegistered(true);
      }
    }, 1200);

    return () => clearInterval(interval);
  }, [isInView, reducedMotion]);

  // Card 3: Gate scan laser loop
  const [isScanned, setIsScanned] = useState(false);
  useEffect(() => {
    if (!isInView || reducedMotion) return;

    const scanInterval = setInterval(() => {
      setIsScanned((prev) => !prev);
    }, 2400);

    return () => clearInterval(scanInterval);
  }, [isInView, reducedMotion]);

  return (
    <section id="how-it-works" ref={sectionRef} className="py-[72px] lg:py-[120px] relative">
      <div className="max-w-[1200px] mx-auto px-6">
        <SectionHeading
          eyebrow={data.eyebrow}
          headingParts={data.headingParts}
          subtitle={data.subtitle}
          align="center"
          className="mb-14"
        />

        {/* 3 Tall Designjoy-style Gradient Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8">
          {/* 1. DISCOVER CARD (Sky Mesh) */}
          <motion.div
            initial={{ opacity: 0, y: 28 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.05 }}
            whileHover={reducedMotion ? undefined : { y: -6, rotateX: 2, rotateY: -3 }}
            className="flex flex-col h-full perspective-[1000px]"
          >
            <MeshCard recipe="sky" className="p-6 sm:p-7 flex-1 flex flex-col justify-between">
              {/* Mini Animated UI on Top */}
              <div className="h-[220px] rounded-[22px] bg-white/95 text-[var(--ink)] p-4 shadow-[0_12px_32px_rgba(0,0,0,0.12)] border border-white/60 flex flex-col justify-between overflow-hidden">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-bold text-[var(--blue)] uppercase tracking-wider">
                      Live Campus Feed
                    </span>
                    <span className="w-2 h-2 rounded-full bg-[#10B981] animate-ping" />
                  </div>

                  {/* Auto-scrolling category chips */}
                  <div className="overflow-hidden py-1">
                    <motion.div
                      className="flex gap-2"
                      animate={
                        reducedMotion
                          ? undefined
                          : {
                              x: [0, -100, 0],
                              transition: { duration: 8, repeat: Infinity, ease: "easeInOut" },
                            }
                      }
                    >
                      {discoverCard.previewData.categories.map((cat, i) => (
                        <span
                          key={cat}
                          className={`text-[11px] font-medium px-2.5 py-1 rounded-full whitespace-nowrap ${
                            i === 0
                              ? "bg-[var(--blue)] text-white font-semibold"
                              : "bg-[#F1F5F9] text-[var(--ink-2)]"
                          }`}
                        >
                          {cat}
                        </span>
                      ))}
                    </motion.div>
                  </div>
                </div>

                {/* Event row sliding in */}
                <motion.div
                  initial={{ x: 20, opacity: 0 }}
                  animate={isInView ? { x: 0, opacity: 1 } : {}}
                  transition={{ duration: 0.5, delay: 0.3 }}
                  className="bg-[#F8FAFC] border border-[var(--line)] rounded-[14px] p-3"
                >
                  <div className="flex items-center justify-between text-[10px] font-semibold text-[var(--coral)]">
                    <span>{discoverCard.previewData.upcomingEvent.club}</span>
                    <span className="bg-[#FEF2F2] px-1.5 py-0.5 rounded-full">
                      {discoverCard.previewData.upcomingEvent.badge}
                    </span>
                  </div>
                  <h4 className="font-semibold text-[13px] text-[var(--ink)] mt-1">
                    {discoverCard.previewData.upcomingEvent.title}
                  </h4>
                  {/* Seats progress bar */}
                  <div className="mt-2">
                    <div className="w-full h-1.5 bg-gray-200 rounded-full overflow-hidden">
                      <div className="h-full bg-[var(--coral)] w-[88%] rounded-full" />
                    </div>
                    <span className="text-[10px] text-[var(--ink-3)] font-medium mt-1 inline-block">
                      {discoverCard.previewData.upcomingEvent.seatsText}
                    </span>
                  </div>
                </motion.div>
              </div>

              {/* Title + 1-line description at bottom */}
              <div className="pt-6">
                <span className="text-[11px] font-bold tracking-widest text-white/80 uppercase">
                  STEP {discoverCard.number} · {discoverCard.step}
                </span>
                <h3 className="text-[20px] font-semibold text-white mt-1 leading-snug">
                  {discoverCard.title}
                </h3>
                <p className="text-[14px] text-white/85 mt-2 leading-relaxed">
                  {discoverCard.description}
                </p>
              </div>
            </MeshCard>
          </motion.div>

          {/* 2. REGISTER CARD (Violet Mesh) */}
          <motion.div
            initial={{ opacity: 0, y: 28 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.15 }}
            whileHover={reducedMotion ? undefined : { y: -6, rotateX: 2, rotateY: 0 }}
            className="flex flex-col h-full perspective-[1000px]"
          >
            <MeshCard recipe="violet" className="p-6 sm:p-7 flex-1 flex flex-col justify-between">
              {/* Mini Animated UI on Top */}
              <div className="h-[220px] rounded-[22px] bg-white/95 text-[var(--ink)] p-4 shadow-[0_12px_32px_rgba(0,0,0,0.12)] border border-white/60 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-bold text-[#6366F1] uppercase tracking-wider">
                      Dynamic Form Autofill
                    </span>
                    <span className="text-[10px] font-medium text-[var(--ink-3)]">Profile synced</span>
                  </div>

                  {/* Form fields that fill in one by one */}
                  <div className="flex flex-col gap-2">
                    {registerCard.previewData.fields.map((field, index) => {
                      const isFilled = typedFields >= index + 1;
                      return (
                        <div
                          key={field.label}
                          className="bg-[#F8FAFC] border border-[var(--line)] rounded-[10px] px-2.5 py-1.5 flex items-center justify-between text-[11px]"
                        >
                          <span className="text-[var(--ink-3)] font-medium">{field.label}</span>
                          <span
                            className={`font-semibold transition-opacity duration-300 ${
                              isFilled ? "opacity-100 text-[var(--ink)]" : "opacity-30 text-gray-400"
                            }`}
                          >
                            {isFilled ? field.value : "..."}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Morphing Registration Button */}
                <motion.div
                  className={`w-full py-2 rounded-full text-center text-[12px] font-semibold transition-all duration-300 flex items-center justify-center gap-1.5 ${
                    isRegistered
                      ? "bg-[#10B981] text-white shadow-[0_4px_16px_rgba(16,185,129,0.3)]"
                      : "bg-[#6366F1] text-white"
                  }`}
                >
                  {isRegistered ? (
                    <>
                      <Check size={14} /> You're in!
                    </>
                  ) : (
                    <>Autofilling details...</>
                  )}
                </motion.div>
              </div>

              {/* Title + 1-line description at bottom */}
              <div className="pt-6">
                <span className="text-[11px] font-bold tracking-widest text-white/80 uppercase">
                  STEP {registerCard.number} · {registerCard.step}
                </span>
                <h3 className="text-[20px] font-semibold text-white mt-1 leading-snug">
                  {registerCard.title}
                </h3>
                <p className="text-[14px] text-white/85 mt-2 leading-relaxed">
                  {registerCard.description}
                </p>
              </div>
            </MeshCard>
          </motion.div>

          {/* 3. GET IN CARD (Sunset Mesh) */}
          <motion.div
            initial={{ opacity: 0, y: 28 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.25 }}
            whileHover={reducedMotion ? undefined : { y: -6, rotateX: 2, rotateY: 3 }}
            className="flex flex-col h-full perspective-[1000px]"
          >
            <MeshCard recipe="sunset" className="p-6 sm:p-7 flex-1 flex flex-col justify-between">
              {/* Mini Animated UI on Top */}
              <div className="h-[220px] rounded-[22px] bg-white/95 text-[var(--ink)] p-4 shadow-[0_12px_32px_rgba(0,0,0,0.12)] border border-white/60 flex flex-col items-center justify-center relative overflow-hidden">
                {/* QR code with sweeping laser line */}
                <div className="relative w-28 h-28 bg-[#FFFFFF] rounded-[16px] border border-[var(--line)] p-2.5 shadow-sm flex items-center justify-center">
                  <QrCode size={84} className="text-[var(--ink)]" />

                  {/* Sweeping coral laser */}
                  {!reducedMotion && (
                    <div className="absolute left-1 right-1 h-[2.5px] bg-[var(--coral)] shadow-[0_0_8px_#FF6B8A] animate-laser pointer-events-none" />
                  )}

                  {/* Verified checkmark overlay */}
                  <motion.div
                    animate={
                      isScanned
                        ? { scale: [0, 1.15, 1], opacity: 1 }
                        : { scale: 0, opacity: 0 }
                    }
                    transition={{ duration: 0.3 }}
                    className="absolute inset-0 bg-[#10B981]/90 rounded-[16px] flex flex-col items-center justify-center text-white"
                  >
                    <Check size={28} strokeWidth={3} />
                    <span className="text-[10px] font-bold mt-1">VERIFIED</span>
                  </motion.div>
                </div>

                {/* +80 XP Pop Badge */}
                <motion.div
                  animate={
                    isScanned
                      ? { y: [8, -4, 0], opacity: 1 }
                      : { y: 0, opacity: 0 }
                  }
                  transition={{ duration: 0.35 }}
                  className="mt-3 bg-[#FEF3C7] text-[#D97706] px-3 py-1 rounded-full text-[11px] font-bold flex items-center gap-1 shadow-sm"
                >
                  <Sparkles size={12} />
                  <span>+80 XP CHECK-IN</span>
                </motion.div>
              </div>

              {/* Title + 1-line description at bottom */}
              <div className="pt-6">
                <span className="text-[11px] font-bold tracking-widest text-white/80 uppercase">
                  STEP {getInCard.number} · {getInCard.step}
                </span>
                <h3 className="text-[20px] font-semibold text-white mt-1 leading-snug">
                  {getInCard.title}
                </h3>
                <p className="text-[14px] text-white/85 mt-2 leading-relaxed">
                  {getInCard.description}
                </p>
              </div>
            </MeshCard>
          </motion.div>
        </div>
      </div>
    </section>
  );
}

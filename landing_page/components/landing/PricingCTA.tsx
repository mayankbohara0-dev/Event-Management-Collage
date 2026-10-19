"use client";

import React from "react";
import { motion } from "framer-motion";
import { Check, Clock, Lock, ArrowRight, Sparkles } from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import MeshCard from "@/components/brand/MeshCard";
import MagneticButton from "@/components/brand/MagneticButton";
import Mascot from "@/components/brand/Mascot";
import { landingData } from "@/lib/landing-data";

export default function PricingCTA() {
  const { eyebrow, headingParts, cards, infoTiles } = landingData.pricing;

  return (
    <section className="py-[60px] lg:py-[120px] relative">
      <div className="max-w-[1200px] mx-auto px-5 sm:px-6">
        <SectionHeading
          eyebrow={eyebrow}
          headingParts={headingParts}
          align="center"
          className="mb-10 sm:mb-14"
        />

        {/* Two Designjoy-style cards */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 sm:gap-8 items-stretch">
          {/* Left Card: Sky Mesh Card "Join ZEST" (Students) */}
          <div className="lg:col-span-5 flex flex-col">
            <MeshCard
              recipe="sky"
              className="p-6 sm:p-10 flex-1 flex flex-col justify-between relative overflow-hidden shadow-[0_20px_50px_rgba(0,99,240,0.24)]"
            >
              {/* Mascot trio in corner */}
              <div className="absolute -bottom-4 -right-4 flex items-end -space-x-6 sm:-space-x-8 pointer-events-auto z-20">
                <Mascot size={55} tint="mint" />
                <Mascot size={65} tint="coral" />
                <Mascot size={75} tint="lemon" />
              </div>

              <div>
                <span className="text-[10px] sm:text-[11px] font-bold tracking-widest text-white/80 uppercase">
                  STUDENT APP
                </span>
                <h3 className="text-[26px] sm:text-[38px] font-bold text-white mt-1">
                  {cards.studentCard.title}
                </h3>
                <div className="mt-2 sm:mt-3 flex items-baseline gap-2">
                  <span className="text-[38px] sm:text-[44px] font-extrabold text-white leading-none">
                    {cards.studentCard.price}
                  </span>
                  <span className="text-[13px] sm:text-[14px] text-white/80 font-medium">
                    {cards.studentCard.period}
                  </span>
                </div>
                <p className="text-[14px] sm:text-[15px] text-white/90 mt-2 sm:mt-3 leading-relaxed max-w-[320px]">
                  {cards.studentCard.description}
                </p>

                {/* Checklist */}
                <ul className="mt-4 sm:mt-6 space-y-2 sm:space-y-2.5 text-[13px] sm:text-[14px] text-white/95">
                  {cards.studentCard.highlights.map((item) => (
                    <li key={item} className="flex items-center gap-2">
                      <span className="w-4 h-4 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
                        <Check size={11} strokeWidth={3} className="text-white" />
                      </span>
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="pt-6 sm:pt-8 mt-4 sm:mt-6 border-t border-white/20 relative z-30">
                <MagneticButton
                  variant="secondary"
                  href={cards.studentCard.href}
                  className="w-full sm:w-auto text-center shadow-md"
                >
                  {cards.studentCard.cta}
                </MagneticButton>
              </div>
            </MeshCard>
          </div>

          {/* Right Card: Dark --ink card "For clubs & colleges" (Organizers) */}
          <div className="lg:col-span-7 flex flex-col">
            <div className="rounded-[28px] sm:rounded-[32px] bg-[var(--ink)] p-6 sm:p-10 text-white flex-1 flex flex-col justify-between relative overflow-hidden shadow-[0_20px_50px_rgba(11,18,32,0.22)] border border-gray-800">
              {/* Big yellow-lemon mascot in bottom-right that waves/looks around */}
              <div className="absolute -bottom-4 -right-4 sm:-bottom-6 sm:-right-6 z-20 pointer-events-auto">
                <Mascot size={110} tint="lemon" />
              </div>

              {/* Inner subtle glow */}
              <div className="absolute top-0 right-1/4 w-80 h-80 bg-[var(--core)]/15 rounded-full blur-[100px] pointer-events-none" />

              <div>
                <span className="text-[10px] sm:text-[11px] font-bold tracking-widest text-[var(--sky)] uppercase">
                  ORGANIZER & CLUB SUITE
                </span>
                <h3 className="text-[26px] sm:text-[38px] font-bold text-white mt-1">
                  {cards.organizerCard.title}
                </h3>
                <div className="mt-2 sm:mt-3 flex items-baseline gap-2">
                  <span className="text-[38px] sm:text-[44px] font-extrabold text-white leading-none">
                    {cards.organizerCard.price}
                  </span>
                  <span className="text-[13px] sm:text-[14px] text-gray-400 font-medium">
                    {cards.organizerCard.period}
                  </span>
                </div>
                <p className="text-[15px] text-gray-300 mt-3 leading-relaxed max-w-[460px]">
                  {cards.organizerCard.description}
                </p>

                {/* Feature list in two columns */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-7 max-w-[480px]">
                  <div className="space-y-2.5">
                    {cards.organizerCard.highlightsCol1.map((item) => (
                      <div key={item} className="flex items-center gap-2 text-[13px] text-gray-200">
                        <span className="w-4 h-4 rounded-full bg-[var(--blue)]/30 text-[var(--sky)] flex items-center justify-center flex-shrink-0">
                          <Check size={11} strokeWidth={3} />
                        </span>
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                  <div className="space-y-2.5">
                    {cards.organizerCard.highlightsCol2.map((item) => (
                      <div key={item} className="flex items-center gap-2 text-[13px] text-gray-200">
                        <span className="w-4 h-4 rounded-full bg-[var(--blue)]/30 text-[var(--sky)] flex items-center justify-center flex-shrink-0">
                          <Check size={11} strokeWidth={3} />
                        </span>
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <div className="pt-6 sm:pt-8 mt-4 sm:mt-6 border-t border-gray-800 relative z-30 flex items-center gap-4">
                <MagneticButton
                  variant="primary"
                  href={cards.organizerCard.href}
                  className="w-full sm:w-auto text-center px-8"
                >
                  {cards.organizerCard.cta}
                </MagneticButton>
              </div>
            </div>
          </div>
        </div>

        {/* Two small outline info tiles under cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-6">
          <div className="bg-white rounded-[24px] p-5 border border-[var(--line)] shadow-sm flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-[#ECFDF5] text-[#059669] flex items-center justify-center flex-shrink-0">
              <Clock size={18} />
            </div>
            <div>
              <h4 className="text-[15px] font-bold text-[var(--ink)]">
                {infoTiles[0].title}
              </h4>
              <p className="text-[13px] text-[var(--ink-2)] mt-0.5">
                {infoTiles[0].description}
              </p>
            </div>
          </div>

          <div className="bg-white rounded-[24px] p-5 border border-[var(--line)] shadow-sm flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-[#EFF6FF] text-[var(--blue)] flex items-center justify-center flex-shrink-0">
              <Lock size={18} />
            </div>
            <div>
              <h4 className="text-[15px] font-bold text-[var(--ink)]">
                {infoTiles[1].title}
              </h4>
              <p className="text-[13px] text-[var(--ink-2)] mt-0.5">
                {infoTiles[1].description}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

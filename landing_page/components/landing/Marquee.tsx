"use client";

import React from "react";
import { Users2, Compass } from "lucide-react";
import { landingData } from "@/lib/landing-data";

export default function Marquee() {
  const { heading, clubs } = landingData.socialProof;

  // Duplicate items for continuous seamless loop
  const marqueeItems = [...clubs, ...clubs];

  return (
    <section className="py-12 border-y border-[var(--line)] bg-white/60 relative overflow-hidden select-none">
      {/* Soft edge fade masks */}
      <div className="absolute left-0 top-0 bottom-0 w-24 sm:w-40 bg-gradient-to-r from-[var(--page)] to-transparent z-10 pointer-events-none" />
      <div className="absolute right-0 top-0 bottom-0 w-24 sm:w-40 bg-gradient-to-l from-[var(--page)] to-transparent z-10 pointer-events-none" />

      <div className="max-w-[1200px] mx-auto px-6 mb-6 text-center">
        <p className="eyebrow text-[var(--ink-3)] font-semibold tracking-widest uppercase">
          {heading}
        </p>
      </div>

      <div className="flex overflow-hidden">
        <div className="marquee-track flex items-center gap-3 py-1">
          {marqueeItems.map((club, idx) => (
            <div
              key={`${club.name}-${idx}`}
              className="inline-flex items-center gap-2.5 px-5 py-2.5 rounded-full bg-white border border-[var(--line)] shadow-[0_4px_16px_rgba(11,18,32,0.03)] text-[14px] font-semibold text-[var(--ink)] hover:border-[var(--sky)] hover:text-[var(--blue)] transition-colors whitespace-nowrap cursor-default"
            >
              <span className="w-2 h-2 rounded-full bg-[var(--sky)]" />
              <span>{club.name}</span>
              <span className="text-[11px] font-medium text-[var(--ink-3)] bg-[var(--page)] px-2 py-0.5 rounded-full">
                {club.category}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

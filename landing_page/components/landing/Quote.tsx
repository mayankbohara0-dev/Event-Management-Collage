"use client";

import React from "react";
import { motion } from "framer-motion";
import { Quote as QuoteIcon } from "lucide-react";
import { landingData } from "@/lib/landing-data";

export default function Quote() {
  const { text, author } = landingData.quote;

  return (
    <section className="py-[72px] lg:py-[100px] relative">
      <div className="max-w-[980px] mx-auto px-6 text-center">
        <motion.div
          initial={{ opacity: 0, y: 32 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
          className="flex flex-col items-center"
        >
          {/* Subtle quote icon */}
          <div className="w-12 h-12 rounded-full bg-[var(--sky)]/15 text-[var(--blue)] flex items-center justify-center mb-6">
            <QuoteIcon size={22} className="fill-[var(--blue)]" />
          </div>

          {/* Large centered quote in Instrument Serif non-italic, 44px */}
          <blockquote className="font-serif font-normal text-[28px] sm:text-[38px] md:text-[44px] leading-[1.25] text-[var(--ink)] tracking-[-0.015em] max-w-[860px]">
            {text}
          </blockquote>

          {/* Author row with avatar + role */}
          <div className="mt-8 flex items-center gap-3">
            <div
              className="w-11 h-11 rounded-full text-white font-semibold text-sm flex items-center justify-center shadow-sm"
              style={{ backgroundColor: author.avatarBg }}
            >
              {author.avatarInitials}
            </div>
            <div className="text-left">
              <p className="text-[15px] font-semibold text-[var(--ink)] leading-tight">
                {author.name}
              </p>
              <p className="text-[13px] text-[var(--ink-3)] font-medium">
                {author.role}
              </p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}

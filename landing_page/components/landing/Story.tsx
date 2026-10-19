"use client";

import React, { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion, type MotionValue } from "framer-motion";
import { Heart } from "lucide-react";
import BlobLogo from "@/components/brand/BlobLogo";
import { landingData } from "@/lib/landing-data";

function Word({ children, progress, range }: { children: string; progress: MotionValue<number>; range: [number, number] }) {
  const opacity = useTransform(progress, range, [0.22, 1]);
  return (
    <span className="relative inline-block mr-[0.28em] my-1">
      <motion.span style={{ opacity }} className="text-[var(--ink)] font-medium">
        {children}
      </motion.span>
    </span>
  );
}

export default function Story() {
  const { lines, eyebrow, author } = landingData.story;
  const containerRef = useRef<HTMLDivElement>(null);
  const reducedMotion = useReducedMotion();

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start 0.85", "end 0.35"],
  });

  // Combine words across lines
  const allWords = lines.join(" ").split(/\s+/).filter(Boolean);

  return (
    <section ref={containerRef} className="py-[72px] lg:py-[120px] relative">
      <div className="max-w-[960px] mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
          className="relative bg-white rounded-[32px] p-8 sm:p-14 border border-[var(--line)] shadow-[0_10px_40px_rgba(11,18,32,0.06)] overflow-hidden text-center"
        >
          {/* Subtle inner radial glow */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-96 h-96 bg-gradient-to-b from-[var(--sky)]/10 to-transparent rounded-full blur-[80px] pointer-events-none" />

          {/* Eyebrow */}
          <div className="inline-flex items-center gap-2 mb-8">
            <BlobLogo size={22} />
            <span className="eyebrow">{eyebrow}</span>
          </div>

          {/* Word-by-word scroll reveal text */}
          <div className="text-[22px] sm:text-[28px] md:text-[34px] leading-[1.35] tracking-[-0.015em] max-w-[800px] mx-auto font-sans">
            {reducedMotion
              ? lines.map((line, idx) => (
                  <p key={idx} className="mb-4 text-[var(--ink)]">
                    {line}
                  </p>
                ))
              : allWords.map((word, i) => {
                  const start = i / allWords.length;
                  const end = start + 1 / allWords.length;
                  return (
                    <Word key={i} progress={scrollYProgress} range={[start, end]}>
                      {word}
                    </Word>
                  );
                })}
          </div>

          {/* Footer note */}
          <div className="mt-10 pt-6 border-t border-[var(--line)] inline-flex items-center gap-2 text-[13px] font-semibold text-[var(--ink-3)]">
            <Heart size={14} className="text-[var(--coral)] fill-[var(--coral)]" />
            <span>{author}</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}

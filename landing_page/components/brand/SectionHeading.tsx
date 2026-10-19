"use client";

import React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { wordMaskContainer, wordMaskChild } from "@/lib/motion";

interface HeadingParts {
  prefix: string;
  accent: string;
  suffix?: string;
}

interface SectionHeadingProps {
  eyebrow?: string;
  headingParts: HeadingParts;
  subtitle?: string;
  align?: "left" | "center";
  level?: "h1" | "h2";
  className?: string;
}

export default function SectionHeading({
  eyebrow,
  headingParts,
  subtitle,
  align = "center",
  level = "h2",
  className = "",
}: SectionHeadingProps) {
  const reducedMotion = useReducedMotion();
  const isCenter = align === "center";

  // Split words for animated mask-up
  const prefixWords = headingParts.prefix.trim().split(/\s+/).filter(Boolean);
  const suffixWords = headingParts.suffix ? headingParts.suffix.trim().split(/\s+/).filter(Boolean) : [];

  const Tag = level === "h1" ? "h1" : "h2";
  const tagClass = level === "h1" ? "heading-h1" : "heading-h2";

  return (
    <div
      className={`max-w-[840px] ${isCenter ? "mx-auto text-center" : "text-left"} ${className}`}
    >
      {eyebrow && (
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="inline-flex items-center gap-2 mb-4"
        >
          <span className="w-2 h-2 rounded-full bg-[var(--sky)] animate-pulse" />
          <span className="eyebrow">{eyebrow}</span>
        </motion.div>
      )}

      <Tag className={`${tagClass} relative`}>
        {reducedMotion ? (
          <span>
            {headingParts.prefix}
            <span className="serif-accent text-[var(--blue)] font-serif italic">
              {headingParts.accent}
            </span>
            {headingParts.suffix}
          </span>
        ) : (
          <motion.span
            variants={wordMaskContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="inline"
          >
            {prefixWords.map((word, i) => (
              <span key={`p-${i}`} className="inline-block overflow-hidden pb-1 align-bottom">
                <motion.span variants={wordMaskChild} className="inline-block mr-[0.26em]">
                  {word}
                </motion.span>
              </span>
            ))}

            {/* The single italic serif accent word */}
            <span className="inline-block overflow-hidden pb-1 align-bottom">
              <motion.span
                variants={wordMaskChild}
                className="inline-block serif-accent text-[var(--blue)] font-serif italic mr-[0.26em]"
              >
                {headingParts.accent}
              </motion.span>
            </span>

            {suffixWords.map((word, i) => (
              <span key={`s-${i}`} className="inline-block overflow-hidden pb-1 align-bottom">
                <motion.span variants={wordMaskChild} className="inline-block mr-[0.26em]">
                  {word}
                </motion.span>
              </span>
            ))}
          </motion.span>
        )}
      </Tag>

      {subtitle && (
        <motion.p
          initial={{ opacity: 0, y: 12 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="body-lead mt-5 max-w-[620px] mx-auto text-[var(--ink-2)]"
        >
          {subtitle}
        </motion.p>
      )}
    </div>
  );
}

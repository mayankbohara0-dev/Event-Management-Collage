"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plus, Mail, MessageCircle, ArrowRight } from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import MeshCard from "@/components/brand/MeshCard";
import MagneticButton from "@/components/brand/MagneticButton";
import Mascot from "@/components/brand/Mascot";
import { landingData } from "@/lib/landing-data";

export default function FAQ() {
  const { eyebrow, headingParts, subtitle, questions, contactBox } = landingData.faq;
  const [openId, setOpenId] = useState<string | null>("faq-1");

  const toggleQuestion = (id: string) => {
    setOpenId((prev) => (prev === id ? null : id));
  };

  return (
    <section id="faq" className="py-[60px] lg:py-[120px] relative">
      <div className="max-w-[1200px] mx-auto px-5 sm:px-6">
        <SectionHeading
          eyebrow={eyebrow}
          headingParts={headingParts}
          subtitle={subtitle}
          align="left"
          className="mb-10 sm:mb-14"
        />

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-start">
          {/* Left Column: Accordion (Single-open, smooth height animation, + rotates to x) */}
          <div className="lg:col-span-8 space-y-3.5">
            {questions.map((item) => {
              const isOpen = openId === item.id;

              return (
                <div
                  key={item.id}
                  className="bg-white rounded-[24px] border border-[var(--line)] overflow-hidden shadow-[0_4px_20px_rgba(11,18,32,0.02)] transition-colors hover:border-[var(--sky)]"
                >
                  <button
                    onClick={() => toggleQuestion(item.id)}
                    className="w-full px-6 py-5 text-left flex items-center justify-between gap-4 focus:outline-none focus:ring-2 focus:ring-[var(--blue)]/40 rounded-[24px]"
                    aria-expanded={isOpen}
                  >
                    <span className="text-[16px] sm:text-[17px] font-semibold text-[var(--ink)]">
                      {item.question}
                    </span>
                    <motion.div
                      animate={{ rotate: isOpen ? 45 : 0 }}
                      transition={{ duration: 0.25, ease: "easeInOut" }}
                      className="w-8 h-8 rounded-full bg-[#F1F5F9] text-[var(--ink)] flex items-center justify-center flex-shrink-0"
                    >
                      <Plus size={18} />
                    </motion.div>
                  </button>

                  <AnimatePresence initial={false}>
                    {isOpen && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
                        className="overflow-hidden"
                      >
                        <div className="px-6 pb-6 pt-1 text-[15px] leading-relaxed text-[var(--ink-2)] border-t border-[var(--line)]/50 mt-1">
                          {item.answer}
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              );
            })}
          </div>

          {/* Right Column: Sticky Sky Mesh Card "Questions? Talk to us" */}
          <div className="lg:col-span-4 lg:sticky lg:top-28">
            <MeshCard recipe="sky" className="p-7 sm:p-8 relative overflow-hidden shadow-[0_15px_40px_rgba(0,99,240,0.22)]">
              {/* Corner Mascot */}
              <div className="absolute -top-3 -right-3 z-10 pointer-events-auto">
                <Mascot size={75} tint="lemon" />
              </div>

              <div className="w-10 h-10 rounded-full bg-white/20 text-white flex items-center justify-center mb-4 backdrop-blur-sm">
                <Mail size={18} />
              </div>

              <h3 className="text-[22px] font-bold text-white leading-snug">
                {contactBox.title}
              </h3>
              <p className="text-[14px] text-white/90 mt-2 leading-relaxed">
                {contactBox.description}
              </p>

              <div className="mt-6 pt-6 border-t border-white/20">
                <MagneticButton
                  variant="secondary"
                  href={`mailto:${contactBox.email}`}
                  className="w-full text-center py-3 text-[14px] shadow-sm"
                >
                  {contactBox.cta}
                </MagneticButton>
                <span className="block text-[12px] text-white/70 text-center mt-2.5 font-medium">
                  {contactBox.email}
                </span>
              </div>
            </MeshCard>
          </div>
        </div>
      </div>
    </section>
  );
}

"use client";

import React, { useRef, useState, useEffect } from "react";
import { motion, useReducedMotion } from "framer-motion";
import {
  QrCode,
  SlidersHorizontal,
  Sparkles,
  Trophy,
  CalendarCheck,
  ShieldCheck,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import { landingData, FeatureItem } from "@/lib/landing-data";

const ICON_MAP: Record<string, React.ElementType> = {
  QrCode,
  SlidersHorizontal,
  Sparkles,
  Trophy,
  CalendarCheck,
  ShieldCheck,
};

// 6 distinct gradient schemes for the carousel cards
const TILE_GRADIENTS = [
  "from-[#0AA5F0]/15 via-white to-white",
  "from-[#6366F1]/15 via-white to-white",
  "from-[#FFD84D]/25 via-white to-white",
  "from-[#FF6B8A]/15 via-white to-white",
  "from-[#3DDC97]/20 via-white to-white",
  "from-[#38BDF8]/15 via-white to-white",
];

const ICON_COLORS = [
  "text-[var(--core)]",
  "text-[#6366F1]",
  "text-[#D97706]",
  "text-[var(--coral)]",
  "text-[#059669]",
  "text-[var(--blue)]",
];

export default function FeaturesCarousel() {
  const data = landingData.features;
  const carouselRef = useRef<HTMLDivElement>(null);
  const [canScrollLeft, setCanScrollLeft] = useState(false);
  const [canScrollRight, setCanScrollRight] = useState(true);
  const reducedMotion = useReducedMotion();

  const updateScrollButtons = () => {
    if (!carouselRef.current) return;
    const { scrollLeft, scrollWidth, clientWidth } = carouselRef.current;
    setCanScrollLeft(scrollLeft > 10);
    setCanScrollRight(scrollLeft + clientWidth < scrollWidth - 10);
  };

  useEffect(() => {
    updateScrollButtons();
    const current = carouselRef.current;
    if (current) {
      current.addEventListener("scroll", updateScrollButtons);
      window.addEventListener("resize", updateScrollButtons);
    }
    return () => {
      if (current) current.removeEventListener("scroll", updateScrollButtons);
      window.removeEventListener("resize", updateScrollButtons);
    };
  }, []);

  const scroll = (direction: "left" | "right") => {
    if (!carouselRef.current) return;
    const offset = 340;
    carouselRef.current.scrollBy({
      left: direction === "left" ? -offset : offset,
      behavior: "smooth",
    });
  };

  return (
    <section id="features" className="py-[72px] lg:py-[120px] relative overflow-hidden">
      <div className="max-w-[1200px] mx-auto px-6">
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-12">
          <SectionHeading
            align="left"
            eyebrow={data.eyebrow}
            headingParts={data.headingParts}
            subtitle={data.subtitle}
            className="max-w-[680px]"
          />

          {/* Prev / Next navigation arrow buttons */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => scroll("left")}
              disabled={!canScrollLeft}
              className={`w-12 h-12 rounded-full border border-[var(--line)] bg-white flex items-center justify-center transition-all ${
                canScrollLeft
                  ? "text-[var(--ink)] hover:bg-[#F8FAFC] hover:border-[var(--sky)] cursor-pointer shadow-sm"
                  : "text-gray-300 border-gray-100 cursor-not-allowed"
              }`}
              aria-label="Previous feature"
            >
              <ChevronLeft size={20} />
            </button>
            <button
              onClick={() => scroll("right")}
              disabled={!canScrollRight}
              className={`w-12 h-12 rounded-full border border-[var(--line)] bg-white flex items-center justify-center transition-all ${
                canScrollRight
                  ? "text-[var(--ink)] hover:bg-[#F8FAFC] hover:border-[var(--sky)] cursor-pointer shadow-sm"
                  : "text-gray-300 border-gray-100 cursor-not-allowed"
              }`}
              aria-label="Next feature"
            >
              <ChevronRight size={20} />
            </button>
          </div>
        </div>

        {/* Scroll-snap container */}
        <div
          ref={carouselRef}
          className="flex gap-6 overflow-x-auto pb-8 pt-2 scroll-smooth snap-x snap-mandatory scrollbar-none"
          style={{ scrollbarWidth: "none" }}
        >
          {data.items.map((item, idx) => {
            const Icon = ICON_MAP[item.iconName] || Sparkles;
            const grad = TILE_GRADIENTS[idx % TILE_GRADIENTS.length];
            const iconColor = ICON_COLORS[idx % ICON_COLORS.length];

            return (
              <motion.div
                key={item.id}
                whileHover={
                  reducedMotion
                    ? undefined
                    : {
                        y: -6,
                        boxShadow: "0 20px 45px rgba(11,18,32,0.08)",
                      }
                }
                transition={{ duration: 0.25 }}
                className={`snap-start flex-shrink-0 w-[290px] sm:w-[320px] rounded-[32px] p-7 border border-[var(--line)] bg-gradient-to-b ${grad} shadow-[0_10px_35px_rgba(11,18,32,0.04)] flex flex-col justify-between group select-none`}
              >
                <div>
                  {/* Glossy white glass tile for icon */}
                  <div className="w-16 h-16 rounded-[22px] bg-white/95 backdrop-blur-md border border-white/80 shadow-[0_8px_24px_rgba(11,18,32,0.06)] flex items-center justify-center mb-6 transition-transform group-hover:scale-105">
                    <motion.div
                      whileHover={
                        reducedMotion
                          ? undefined
                          : {
                              rotate: [-6, 6, -3, 3, 0],
                              transition: { duration: 0.4 },
                            }
                      }
                    >
                      <Icon size={28} className={iconColor} />
                    </motion.div>
                  </div>

                  {item.badge && (
                    <span className="text-[11px] font-bold text-[var(--core)] bg-[var(--sky)]/15 px-2.5 py-1 rounded-full uppercase tracking-wider inline-block mb-2">
                      {item.badge}
                    </span>
                  )}

                  <h3 className="text-[19px] font-semibold text-[var(--ink)] mt-1 tracking-tight">
                    {item.title}
                  </h3>
                </div>

                <p className="text-[14px] text-[var(--ink-2)] mt-4 leading-relaxed">
                  {item.description}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

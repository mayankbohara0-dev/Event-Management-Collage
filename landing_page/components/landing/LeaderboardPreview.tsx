"use client";

import React, { useState, useEffect } from "react";
import { motion, useInView, useReducedMotion } from "framer-motion";
import { Trophy, Crown, Flame, Sparkles, CheckCircle2, TrendingUp } from "lucide-react";
import SectionHeading from "@/components/brand/SectionHeading";
import { landingData } from "@/lib/landing-data";

export default function LeaderboardPreview() {
  const { eyebrow, headingParts, subtitle, bullets, podium, rankingRows } =
    landingData.leaderboard;
  const [rows, setRows] = useState(rankingRows);
  const reducedMotion = useReducedMotion();

  // Periodically reorder rows every 4s to simulate "live" campus leaderboard
  useEffect(() => {
    if (reducedMotion) return;

    const interval = setInterval(() => {
      setRows((prev) => {
        const next = [...prev];
        // Swap adjacent items slightly
        const i = Math.floor(Math.random() * (next.length - 1));
        const temp = next[i];
        next[i] = next[i + 1];
        next[i + 1] = temp;
        return next;
      });
    }, 4000);

    return () => clearInterval(interval);
  }, [reducedMotion]);

  return (
    <section className="py-[72px] lg:py-[120px] relative">
      <div className="max-w-[1200px] mx-auto px-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          {/* Left Column: Copy & Bullets */}
          <div className="lg:col-span-5 text-left">
            <SectionHeading
              align="left"
              eyebrow={eyebrow}
              headingParts={headingParts}
              subtitle={subtitle}
              className="max-w-none"
            />

            {/* 3 Bullets */}
            <div className="mt-8 space-y-4">
              {bullets.map((bullet, idx) => (
                <motion.div
                  key={bullet.title}
                  initial={{ opacity: 0, x: -16 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: idx * 0.1 }}
                  className="flex items-start gap-3.5"
                >
                  <div className="w-9 h-9 rounded-full bg-[var(--sky)]/15 text-[var(--blue)] flex items-center justify-center flex-shrink-0 mt-0.5">
                    {idx === 0 ? (
                      <Trophy size={16} />
                    ) : idx === 1 ? (
                      <Sparkles size={16} />
                    ) : (
                      <Flame size={16} />
                    )}
                  </div>
                  <div>
                    <h4 className="text-[15px] font-semibold text-[var(--ink)]">
                      {bullet.title}
                    </h4>
                    <p className="text-[13px] text-[var(--ink-2)] mt-0.5 leading-relaxed">
                      {bullet.desc}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Right Column: Animated Podium + Ranking Rows */}
          <div className="lg:col-span-7 bg-white rounded-[32px] p-6 sm:p-8 border border-[var(--line)] shadow-[0_10px_40px_rgba(11,18,32,0.06)]">
            {/* Header with live dot */}
            <div className="flex items-center justify-between pb-6 border-b border-[var(--line)]">
              <div>
                <span className="text-[11px] font-bold uppercase tracking-wider text-[var(--ink-3)]">
                  Weekly Campus Arena
                </span>
                <h3 className="text-[18px] font-bold text-[var(--ink)]">
                  Top Event Explorers
                </h3>
              </div>
              <div className="flex items-center gap-2 bg-[#ECFDF5] border border-[#A7F3D0] px-3 py-1 rounded-full text-[12px] font-bold text-[#059669]">
                <span className="w-2 h-2 rounded-full bg-[#10B981] animate-ping" />
                <span>LIVE</span>
              </div>
            </div>

            {/* Animated Podium (1st taller in center with Crown, 2nd, 3rd) */}
            <div className="pt-8 pb-6 flex items-end justify-center gap-3 sm:gap-6 border-b border-[var(--line)] select-none">
              {/* 2nd Place */}
              <div className="flex flex-col items-center flex-1 max-w-[110px]">
                <div className="w-11 h-11 rounded-full bg-[#E2E8F0] border-2 border-white shadow-md flex items-center justify-center text-[13px] font-bold text-gray-700 mb-1.5">
                  {podium[1].name.substring(0, 2)}
                </div>
                <span className="text-[12px] font-semibold text-[var(--ink)] truncate max-w-[90px]">
                  {podium[1].name}
                </span>
                <span className="text-[11px] font-bold text-[var(--blue)]">
                  {podium[1].xp} XP
                </span>
                <motion.div
                  initial={{ height: 0 }}
                  whileInView={{ height: 85 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: 0.1 }}
                  className="w-full bg-[#F1F5F9] rounded-t-[14px] mt-2 flex flex-col items-center justify-center text-gray-400 font-bold text-[18px] border border-[var(--line)]"
                >
                  2
                </motion.div>
              </div>

              {/* 1st Place (Taller with Crown) */}
              <div className="flex flex-col items-center flex-1 max-w-[125px]">
                <Crown size={22} className="text-[#F59E0B] fill-[#F59E0B] mb-1 animate-bounce" />
                <div className="w-13 h-13 rounded-full bg-gradient-to-tr from-[#FDE68A] to-[#F59E0B] border-2 border-white shadow-lg flex items-center justify-center text-[14px] font-bold text-white mb-1.5 p-0.5">
                  <div className="w-full h-full rounded-full bg-white flex items-center justify-center text-[#B45309]">
                    {podium[0].name.substring(0, 2)}
                  </div>
                </div>
                <span className="text-[13px] font-bold text-[var(--ink)] truncate max-w-[100px]">
                  {podium[0].name}
                </span>
                <span className="text-[12px] font-extrabold text-[#D97706]">
                  {podium[0].xp} XP
                </span>
                <motion.div
                  initial={{ height: 0 }}
                  whileInView={{ height: 120 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6 }}
                  className="w-full bg-gradient-to-t from-[#FEF3C7] to-[#FDE68A]/60 rounded-t-[16px] mt-2 flex flex-col items-center justify-center text-[#B45309] font-bold text-[22px] border border-[#FDE68A]"
                >
                  1
                </motion.div>
              </div>

              {/* 3rd Place */}
              <div className="flex flex-col items-center flex-1 max-w-[110px]">
                <div className="w-11 h-11 rounded-full bg-[#FED7AA] border-2 border-white shadow-md flex items-center justify-center text-[13px] font-bold text-[#9A3412] mb-1.5">
                  {podium[2].name.substring(0, 2)}
                </div>
                <span className="text-[12px] font-semibold text-[var(--ink)] truncate max-w-[90px]">
                  {podium[2].name}
                </span>
                <span className="text-[11px] font-bold text-[var(--blue)]">
                  {podium[2].xp} XP
                </span>
                <motion.div
                  initial={{ height: 0 }}
                  whileInView={{ height: 65 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: 0.2 }}
                  className="w-full bg-[#FFEDD5] rounded-t-[14px] mt-2 flex flex-col items-center justify-center text-[#9A3412] font-bold text-[18px] border border-[#FED7AA]"
                >
                  3
                </motion.div>
              </div>
            </div>

            {/* 4 Ranking Rows with progress bars and Framer layout reordering */}
            <div className="pt-4 space-y-2.5">
              {rows.map((user, idx) => {
                const maxXP = 2600;
                const percentage = Math.round((user.xp / maxXP) * 100);

                return (
                  <motion.div
                    key={user.id}
                    layout={!reducedMotion}
                    transition={{ type: "spring", stiffness: 350, damping: 30 }}
                    className="p-3 rounded-[16px] bg-[#F8FAFC] border border-[var(--line)] flex items-center justify-between text-[13px] hover:border-[var(--sky)] transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <span className="w-5 text-center font-bold text-[var(--ink-3)] text-xs">
                        #{idx + 4}
                      </span>
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-[var(--ink)]">
                            {user.name}
                          </span>
                          <span className="text-[10px] text-[var(--ink-3)] bg-white px-2 py-0.5 rounded-full border border-[var(--line)] font-medium">
                            {user.tag}
                          </span>
                        </div>
                        {/* Progress Bar */}
                        <div className="w-36 sm:w-48 h-1.5 bg-gray-200 rounded-full mt-1.5 overflow-hidden">
                          <motion.div
                            initial={{ width: 0 }}
                            whileInView={{ width: `${percentage}%` }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.8, delay: idx * 0.1 }}
                            className="h-full bg-gradient-to-r from-[var(--sky)] to-[var(--blue)] rounded-full"
                          />
                        </div>
                      </div>
                    </div>

                    <div className="text-right">
                      <span className="font-bold text-[var(--blue)] text-[13px]">
                        {user.xp} XP
                      </span>
                      <span className="text-[10px] text-[var(--ink-3)] block font-medium">
                        Lvl {user.level} · {user.streak}d streak
                      </span>
                    </div>
                  </motion.div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

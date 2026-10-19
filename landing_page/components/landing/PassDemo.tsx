"use client";

import React, { useState, useRef } from "react";
import { motion, useMotionValue, useTransform, useReducedMotion } from "framer-motion";
import { QrCode, Sparkles, Check, RotateCcw, Calendar, MapPin, User, ShieldCheck } from "lucide-react";
import confetti from "canvas-confetti";
import SectionHeading from "@/components/brand/SectionHeading";
import MagneticButton from "@/components/brand/MagneticButton";
import BlobLogo from "@/components/brand/BlobLogo";
import { landingData } from "@/lib/landing-data";

export default function PassDemo() {
  const { eyebrow, headingParts, subtitle, ticket } = landingData.passDemo;
  const [isScanned, setIsScanned] = useState(false);
  const [xpCount, setXpCount] = useState(0);
  const [isScanning, setIsScanning] = useState(false);
  const [flash, setFlash] = useState(false);
  const ticketRef = useRef<HTMLDivElement>(null);
  const reducedMotion = useReducedMotion();

  // 3D tilt & specular glare
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);
  const rotateX = useTransform(mouseY, [-200, 200], [8, -8]);
  const rotateY = useTransform(mouseX, [-200, 200], [-8, 8]);
  const glareX = useTransform(mouseX, [-200, 200], [0, 100]);
  const glareY = useTransform(mouseY, [-200, 200], [0, 100]);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (reducedMotion || !ticketRef.current) return;
    const rect = ticketRef.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    mouseX.set(e.clientX - centerX);
    mouseY.set(e.clientY - centerY);
  };

  const handleMouseLeave = () => {
    mouseX.set(0);
    mouseY.set(0);
  };

  const handleScan = () => {
    if (isScanned || isScanning) return;
    setIsScanning(true);

    // Laser speed up & flash
    setTimeout(() => {
      setFlash(true);
      setTimeout(() => setFlash(false), 250);

      setIsScanned(true);
      setIsScanning(false);

      // Lightweight confetti burst: 40 particles, 900ms
      if (!reducedMotion) {
        confetti({
          particleCount: 40,
          spread: 60,
          origin: { y: 0.65 },
          colors: ["#38BDF8", "#0AA5F0", "#FFD84D", "#FF6B8A", "#3DDC97"],
          ticks: 120,
        });
      }

      // XP counter counts up to +80
      let currentXp = 0;
      const step = 4;
      const timer = setInterval(() => {
        currentXp += step;
        if (currentXp >= 80) {
          setXpCount(80);
          clearInterval(timer);
        } else {
          setXpCount(currentXp);
        }
      }, 30);
    }, 600);
  };

  const handleReset = () => {
    setIsScanned(false);
    setXpCount(0);
    setIsScanning(false);
  };

  return (
    <section className="py-[72px] lg:py-[120px] relative overflow-hidden bg-white/40">
      <div className="max-w-[1200px] mx-auto px-6 text-center">
        <SectionHeading
          eyebrow={eyebrow}
          headingParts={headingParts}
          subtitle={subtitle}
          align="center"
          className="mb-14"
        />

        {/* Center: Sky-gradient ticket with circular side notches and dashed perforation */}
        <div className="flex flex-col items-center justify-center perspective-[1200px]">
          <motion.div
            ref={ticketRef}
            onMouseMove={handleMouseMove}
            onMouseLeave={handleMouseLeave}
            style={{
              rotateX: reducedMotion ? 0 : rotateX,
              rotateY: reducedMotion ? 0 : rotateY,
              transformStyle: "preserve-3d",
            }}
            className="w-full max-w-[420px] relative transition-transform duration-150 select-none"
          >
            {/* White flash overlay on scan */}
            {flash && (
              <motion.div
                initial={{ opacity: 0.8 }}
                animate={{ opacity: 0 }}
                transition={{ duration: 0.25 }}
                className="absolute inset-0 bg-white z-50 rounded-[32px] pointer-events-none"
              />
            )}

            {/* Main Sky-Gradient Ticket Body */}
            <div className="relative rounded-[32px] bg-gradient-to-br from-[#38BDF8] via-[#0AA5F0] to-[#0063F0] p-6 text-white shadow-[0_20px_60px_rgba(0,99,240,0.3)] border border-white/40 overflow-hidden text-left">
              {/* Specular glare highlight following cursor */}
              {!reducedMotion && (
                <motion.div
                  className="absolute inset-0 pointer-events-none opacity-25 bg-[radial-gradient(circle_at_var(--gx)_var(--gy),rgba(255,255,255,0.8)_0%,transparent_60%)]"
                  style={
                    {
                      "--gx": useTransform(glareX, (v) => `${v}%`),
                      "--gy": useTransform(glareY, (v) => `${v}%`),
                    } as any
                  }
                />
              )}

              {/* Ticket Header */}
              <div className="flex items-center justify-between pb-4 border-b border-white/20">
                <div className="flex items-center gap-2">
                  <BlobLogo size={28} />
                  <div>
                    <span className="text-[10px] tracking-widest font-bold uppercase text-white/80">
                      {ticket.college}
                    </span>
                    <h4 className="text-[14px] font-bold text-white leading-tight">
                      ZEST Event Pass
                    </h4>
                  </div>
                </div>

                {/* Status Pill */}
                <div
                  className={`px-3 py-1 rounded-full text-[11px] font-bold flex items-center gap-1 transition-colors ${
                    isScanned
                      ? "bg-[#10B981] text-white"
                      : "bg-white/25 text-white backdrop-blur-sm"
                  }`}
                >
                  {isScanned ? (
                    <>
                      <Check size={12} strokeWidth={3} /> Attended ✓
                    </>
                  ) : (
                    <>Valid Entry</>
                  )}
                </div>
              </div>

              {/* Event Information */}
              <div className="py-4">
                <span className="text-[10px] uppercase font-bold tracking-wider text-[#FFD84D]">
                  OFFICIAL BADGE
                </span>
                <h3 className="text-[18px] sm:text-[20px] font-bold text-white mt-0.5 leading-snug">
                  {ticket.eventName}
                </h3>

                <div className="grid grid-cols-2 gap-3 mt-3.5 text-[12px] text-white/90">
                  <div className="flex items-center gap-1.5">
                    <Calendar size={13} className="text-[#6CE3FF]" />
                    <span>{ticket.date}</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <MapPin size={13} className="text-[#FFD84D]" />
                    <span className="truncate">{ticket.venue}</span>
                  </div>
                </div>
              </div>

              {/* Circular side notches & dashed perforation */}
              <div className="relative my-2 flex items-center justify-center">
                <div className="absolute -left-[38px] w-8 h-8 rounded-full bg-[var(--page)] border-r border-[var(--line)] shadow-inner" />
                <div className="w-full border-b border-dashed border-white/35" />
                <div className="absolute -right-[38px] w-8 h-8 rounded-full bg-[var(--page)] border-l border-[var(--line)] shadow-inner" />
              </div>

              {/* Bottom attendee row & White rounded QR tile */}
              <div className="pt-3 flex items-center justify-between">
                <div>
                  <span className="text-[10px] uppercase text-white/70 font-semibold block">
                    Attendee
                  </span>
                  <span className="text-[14px] font-bold text-white block">
                    {ticket.attendee}
                  </span>
                  <span className="text-[11px] font-mono text-white/80 block mt-0.5">
                    {ticket.rollNo}
                  </span>
                  <div className="mt-2 text-[10px] text-white/60 font-mono">
                    ID: {ticket.ticketId}
                  </div>
                </div>

                {/* White rounded QR tile with sweeping laser line */}
                <div className="relative w-24 h-24 bg-white rounded-[18px] p-2 flex items-center justify-center shadow-md overflow-hidden">
                  <QrCode size={76} className="text-[var(--ink)]" />

                  {/* Coral laser line */}
                  {!isScanned && (
                    <motion.div
                      animate={{
                        top: ["0%", "100%", "0%"],
                      }}
                      transition={{
                        duration: isScanning ? 0.6 : 2.2,
                        repeat: Infinity,
                        ease: "easeInOut",
                      }}
                      className="absolute left-1 right-1 h-[2.5px] bg-[var(--coral)] shadow-[0_0_8px_#FF6B8A] pointer-events-none"
                    />
                  )}

                  {/* Scanned Checkmark Overlay */}
                  {isScanned && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="absolute inset-0 bg-[#10B981] flex flex-col items-center justify-center text-white"
                    >
                      <Check size={32} strokeWidth={3} />
                      <span className="text-[9px] font-bold mt-1">CHECKED IN</span>
                    </motion.div>
                  )}
                </div>
              </div>
            </div>
          </motion.div>

          {/* Interactive Scan Action & XP Counter */}
          <div className="mt-8 flex flex-col items-center gap-3">
            <div className="flex items-center gap-4">
              <MagneticButton
                variant="primary"
                onClick={handleScan}
                ariaLabel="Scan Pass Demo"
                className="px-8 py-3.5 text-[16px] shadow-[0_10px_25px_rgba(0,99,240,0.35)]"
              >
                {isScanning ? (
                  "Scanning Pass..."
                ) : isScanned ? (
                  <span className="flex items-center gap-1.5">
                    <Check size={16} strokeWidth={3} /> Pass Verified (+80 XP)
                  </span>
                ) : (
                  "Scan it"
                )}
              </MagneticButton>

              {isScanned && (
                <button
                  onClick={handleReset}
                  className="flex items-center gap-1.5 text-[14px] font-semibold text-[var(--ink-2)] hover:text-[var(--ink)] transition-colors px-3 py-2 rounded-full hover:bg-gray-100"
                >
                  <RotateCcw size={15} />
                  <span>Reset</span>
                </button>
              )}
            </div>

            {/* XP Count Pill with live counter */}
            {isScanned && (
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="mt-2 bg-[#FEF3C7] border border-[#FDE68A] text-[#B45309] px-4 py-1.5 rounded-full text-[13px] font-bold flex items-center gap-2 shadow-sm"
              >
                <Sparkles size={14} className="text-[#F59E0B]" />
                <span>Awarded +{xpCount} Campus XP to {ticket.attendee}</span>
              </motion.div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}

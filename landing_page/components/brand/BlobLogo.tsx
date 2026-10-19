"use client";

import React from "react";
import { motion } from "framer-motion";

interface BlobLogoProps {
  size?: number;
  className?: string;
  animateOnLoad?: boolean;
}

/**
 * BlobLogo — exact SVG geometry matching Section 3 specification
 * viewBox: 0 0 160 160
 * Squircle rect rx 38 filled with brand gradient
 * Lemon group: ellipse cx80 cy84 rx42 ry31 rotate(-18 80 84) + circle (118,71) r8.5 + circle (42,97) r8.5
 * Layer 1: fill & stroke #fff, width 24, linejoin round, blur 1.2
 * Layer 2: fill & stroke #0AA5F0, stroke width 8, blur 5.5
 * Leaf: white ellipse cx90 cy45 rx13 ry6 rotate(-30)
 * Eyes: ellipses (68,85) and (93,79), rx6.5 ry10 rotate(-8), fill gradient white -> #A9DBFF
 */
export default function BlobLogo({
  size = 40,
  className = "",
  animateOnLoad = false,
}: BlobLogoProps) {
  const content = (
    <svg
      viewBox="0 0 160 160"
      width={size}
      height={size}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className="overflow-visible select-none"
      role="img"
      aria-label="ZEST Logo"
    >
      <defs>
        {/* Brand linear gradient (180deg: #38BDF8 -> #0063F0) */}
        <linearGradient id="zestBrandGrad" x1="80" y1="0" x2="80" y2="160" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stopColor="#38BDF8" />
          <stop offset="100%" stopColor="#0063F0" />
        </linearGradient>

        {/* Eye vertical gradient: white -> #A9DBFF */}
        <linearGradient id="zestEyeGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#FFFFFF" />
          <stop offset="100%" stopColor="#A9DBFF" />
        </linearGradient>

        {/* Filter Layer 1: Gaussian blur stdDev 1.2 */}
        <filter
          id="zestGlowEdge"
          filterUnits="userSpaceOnUse"
          x="-20"
          y="-20"
          width="200"
          height="200"
        >
          <feGaussianBlur stdDeviation="1.2" />
        </filter>

        {/* Filter Layer 2: Gaussian blur stdDev 5.5 */}
        <filter
          id="zestGlowCore"
          filterUnits="userSpaceOnUse"
          x="-20"
          y="-20"
          width="200"
          height="200"
        >
          <feGaussianBlur stdDeviation="5.5" />
        </filter>
      </defs>

      {/* Squircle base */}
      <rect width="160" height="160" rx="38" fill="url(#zestBrandGrad)" />

      {/* Layer 1 (Glow Edge) */}
      <g
        filter="url(#zestGlowEdge)"
        fill="#FFFFFF"
        stroke="#FFFFFF"
        strokeWidth="24"
        strokeLinejoin="round"
      >
        <ellipse cx="80" cy="84" rx="42" ry="31" transform="rotate(-18 80 84)" />
        <circle cx="118" cy="71" r="8.5" />
        <circle cx="42" cy="97" r="8.5" />
      </g>

      {/* Layer 2 (Core Glow) */}
      <g
        filter="url(#zestGlowCore)"
        fill="#0AA5F0"
        stroke="#0AA5F0"
        strokeWidth="8"
        strokeLinejoin="round"
      >
        <ellipse cx="80" cy="84" rx="42" ry="31" transform="rotate(-18 80 84)" />
        <circle cx="118" cy="71" r="8.5" />
        <circle cx="42" cy="97" r="8.5" />
      </g>

      {/* Solid crisp lemon body */}
      <g fill="#0AA5F0">
        <ellipse cx="80" cy="84" rx="42" ry="31" transform="rotate(-18 80 84)" />
        <circle cx="118" cy="71" r="8.5" />
        <circle cx="42" cy="97" r="8.5" />
      </g>

      {/* Leaf */}
      <ellipse
        cx="90"
        cy="45"
        rx="13"
        ry="6"
        transform="rotate(-30 90 45)"
        fill="#FFFFFF"
      />

      {/* Eyes */}
      <motion.ellipse
        cx="68"
        cy="85"
        rx="6.5"
        ry="10"
        transform="rotate(-8 68 85)"
        fill="url(#zestEyeGrad)"
        animate={
          animateOnLoad
            ? {
                scaleY: [1, 0.1, 1],
                transition: { delay: 1, duration: 0.16, ease: "easeInOut" },
              }
            : undefined
        }
        style={{ transformOrigin: "68px 85px" }}
      />
      <motion.ellipse
        cx="93"
        cy="79"
        rx="6.5"
        ry="10"
        transform="rotate(-8 93 79)"
        fill="url(#zestEyeGrad)"
        animate={
          animateOnLoad
            ? {
                scaleY: [1, 0.1, 1],
                transition: { delay: 1, duration: 0.16, ease: "easeInOut" },
              }
            : undefined
        }
        style={{ transformOrigin: "93px 79px" }}
      />
    </svg>
  );

  if (animateOnLoad) {
    return (
      <motion.div
        className={`inline-flex items-center justify-center ${className}`}
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ type: "spring", stiffness: 280, damping: 20 }}
      >
        {content}
      </motion.div>
    );
  }

  return <div className={`inline-flex items-center justify-center ${className}`}>{content}</div>;
}

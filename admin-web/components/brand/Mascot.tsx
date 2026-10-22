"use client";

import React, { useEffect, useState, useId } from "react";
import { motion } from "framer-motion";

export type MascotMood = "idle" | "happy" | "sleepy" | "celebrate";
export type MascotTint = "blue" | "lemon" | "coral" | "lavender" | "mint" | "aqua";

interface MascotProps {
  size?: number;
  mood?: MascotMood;
  tint?: MascotTint;
  className?: string;
  onClick?: () => void;
}

const TINT_FILLS: Record<MascotTint, string> = {
  blue: "#0AA5F0",
  lemon: "#FFD84D",
  coral: "#FF6B8A",
  lavender: "#8E8BEA",
  mint: "#3DDC97",
  aqua: "#6CE3FF",
};

const TINT_GLOWS: Record<MascotTint, string> = {
  blue: "#38BDF8",
  lemon: "#FDE047",
  coral: "#FDA4AF",
  lavender: "#C7D2FE",
  mint: "#6EE7B7",
  aqua: "#BAE6FD",
};

export function Mascot({
  size = 80,
  mood = "idle",
  tint = "blue",
  className = "",
  onClick,
}: MascotProps) {
  const id = useId().replace(/:/g, "_");
  const [isBlinking, setIsBlinking] = useState(false);

  // Blinking loop every 3 to 5 seconds
  useEffect(() => {
    let timeout: NodeJS.Timeout;

    const scheduleBlink = () => {
      const nextTime = 3000 + Math.random() * 2200;
      timeout = setTimeout(() => {
        setIsBlinking(true);
        setTimeout(() => {
          setIsBlinking(false);
          scheduleBlink();
        }, 160);
      }, nextTime);
    };

    scheduleBlink();
    return () => clearTimeout(timeout);
  }, []);

  const fillColor = TINT_FILLS[tint];
  const glowColor = TINT_GLOWS[tint];
  const glowFilterId = `mascot-glow-${id}`;

  return (
    <motion.div
      className={`inline-block select-none ${onClick ? "cursor-pointer" : ""} ${className}`}
      style={{ width: size, height: size }}
      animate={
        mood === "celebrate"
          ? { y: [0, -12, 0, -8, 0], scale: [1, 1.05, 1, 1.03, 1] }
          : { y: [0, -4, 0] }
      }
      transition={{
        duration: mood === "celebrate" ? 1.6 : 2.4,
        repeat: Infinity,
        ease: "easeInOut",
      }}
      whileTap={onClick ? { scale: 0.92 } : undefined}
      onClick={onClick}
    >
      <svg
        width={size}
        height={size}
        viewBox="0 0 160 160"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <filter
            id={glowFilterId}
            x="-20"
            y="-20"
            width="200"
            height="200"
            filterUnits="userSpaceOnUse"
          >
            <feGaussianBlur stdDeviation="6" result="blur" />
          </filter>
        </defs>

        {/* Glow Layer */}
        <g filter={`url(#${glowFilterId})`}>
          <ellipse
            cx="80"
            cy="84"
            rx="42"
            ry="31"
            transform="rotate(-18 80 84)"
            fill={glowColor}
            opacity={0.6}
          />
          <circle cx="118" cy="71" r="8.5" fill={glowColor} opacity={0.6} />
          <circle cx="42" cy="97" r="8.5" fill={glowColor} opacity={0.6} />
        </g>

        {/* Crisp Edge Stroke */}
        <g>
          <ellipse
            cx="80"
            cy="84"
            rx="42"
            ry="31"
            transform="rotate(-18 80 84)"
            stroke="#FFFFFF"
            strokeWidth="3.5"
            fill="none"
          />
          <circle cx="118" cy="71" r="8.5" stroke="#FFFFFF" strokeWidth="3.5" fill="none" />
          <circle cx="42" cy="97" r="8.5" stroke="#FFFFFF" strokeWidth="3.5" fill="none" />
        </g>

        {/* Solid Mascot Body */}
        <g>
          <ellipse
            cx="80"
            cy="84"
            rx="42"
            ry="31"
            transform="rotate(-18 80 84)"
            fill={fillColor}
          />
          <circle cx="118" cy="71" r="8.5" fill={fillColor} />
          <circle cx="42" cy="97" r="8.5" fill={fillColor} />
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

        {/* Eyes according to mood */}
        {mood === "happy" || mood === "celebrate" ? (
          // Happy curved arcs
          <g stroke="#0B1220" strokeWidth="3" strokeLinecap="round" fill="none">
            <path d="M 62 88 Q 68 81 74 88" />
            <path d="M 87 82 Q 93 75 99 82" />
          </g>
        ) : mood === "sleepy" ? (
          // Sleepy horizontal slits
          <g stroke="#0B1220" strokeWidth="2.5" strokeLinecap="round">
            <line x1="62" y1="85" x2="74" y2="85" />
            <line x1="87" y1="79" x2="99" y2="79" />
          </g>
        ) : isBlinking ? (
          // Closed eye during blink
          <g stroke="#0B1220" strokeWidth="2.5" strokeLinecap="round">
            <line x1="62" y1="85" x2="74" y2="85" />
            <line x1="87" y1="79" x2="99" y2="79" />
          </g>
        ) : (
          // Normal idle eyes
          <g>
            {/* Left Eye */}
            <ellipse
              cx="68"
              cy="85"
              rx="6.5"
              ry="10"
              transform="rotate(-8 68 85)"
              fill="#FFFFFF"
              stroke="#0B1220"
              strokeWidth="1.2"
            />
            <circle cx="69" cy="85" r="2.2" fill="#0B1220" />

            {/* Right Eye */}
            <ellipse
              cx="93"
              cy="79"
              rx="6.5"
              ry="10"
              transform="rotate(-8 93 79)"
              fill="#FFFFFF"
              stroke="#0B1220"
              strokeWidth="1.2"
            />
            <circle cx="94" cy="79" r="2.2" fill="#0B1220" />
          </g>
        )}

        {/* Celebrate Sparkles */}
        {mood === "celebrate" && (
          <g fill="#FFD84D">
            <circle cx="120" cy="35" r="3" />
            <circle cx="30" cy="55" r="2.5" />
            <circle cx="135" cy="80" r="2" />
          </g>
        )}
      </svg>
    </motion.div>
  );
}

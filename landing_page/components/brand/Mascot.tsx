"use client";

import React, { useEffect, useState, useRef } from "react";
import { motion, useReducedMotion } from "framer-motion";

export type MascotTint = "blue" | "lemon" | "coral" | "lavender" | "mint" | "aqua";

interface MascotProps {
  size?: number;
  tint?: MascotTint;
  className?: string;
  interactive?: boolean;
  onClick?: () => void;
}

const TINT_CONFIG: Record<
  MascotTint,
  {
    fill: string;
    glow: string;
    edge: string;
    leaf: string;
    eyeGradient: [string, string];
  }
> = {
  blue: {
    fill: "#0AA5F0",
    glow: "#38BDF8",
    edge: "#FFFFFF",
    leaf: "#FFFFFF",
    eyeGradient: ["#FFFFFF", "#A9DBFF"],
  },
  lemon: {
    fill: "#FFD84D",
    glow: "#FDE047",
    edge: "#FFFFFF",
    leaf: "#3DDC97",
    eyeGradient: ["#FFFFFF", "#FDE68A"],
  },
  coral: {
    fill: "#FF6B8A",
    glow: "#FDA4AF",
    edge: "#FFFFFF",
    leaf: "#6CE3FF",
    eyeGradient: ["#FFFFFF", "#FECDD3"],
  },
  lavender: {
    fill: "#8E8BEA",
    glow: "#C7D2FE",
    edge: "#FFFFFF",
    leaf: "#FFD84D",
    eyeGradient: ["#FFFFFF", "#E0E7FF"],
  },
  mint: {
    fill: "#3DDC97",
    glow: "#6EE7B7",
    edge: "#FFFFFF",
    leaf: "#FF6B8A",
    eyeGradient: ["#FFFFFF", "#D1FAE5"],
  },
  aqua: {
    fill: "#6CE3FF",
    glow: "#BAE6FD",
    edge: "#FFFFFF",
    leaf: "#FFD84D",
    eyeGradient: ["#FFFFFF", "#E0F2FE"],
  },
};

export default function Mascot({
  size = 120,
  tint = "blue",
  className = "",
  interactive = true,
  onClick,
}: MascotProps) {
  const reducedMotion = useReducedMotion();
  const mascotRef = useRef<HTMLDivElement>(null);

  const [isBlinking, setIsBlinking] = useState(false);
  const [eyeOffset, setEyeOffset] = useState({ x: 0, y: 0 });

  const colors = TINT_CONFIG[tint] || TINT_CONFIG.blue;
  const rawId = React.useId();
  const cleanId = rawId.replace(/[^a-zA-Z0-9-_]/g, "");
  const gradientId = `mascot-grad-${tint}-${cleanId}`;
  const filterId = `mascot-filter-${tint}-${cleanId}`;

  // Random eye blinking loop (every 3-5 seconds, duration 120ms)
  useEffect(() => {
    if (reducedMotion) return;

    let timeoutId: NodeJS.Timeout;
    const scheduleBlink = () => {
      const delay = Math.random() * 2000 + 3000; // 3 to 5s
      timeoutId = setTimeout(() => {
        setIsBlinking(true);
        setTimeout(() => {
          setIsBlinking(false);
          scheduleBlink();
        }, 120);
      }, delay);
    };

    scheduleBlink();
    return () => clearTimeout(timeoutId);
  }, [reducedMotion]);

  // Eye cursor tracking (max 4px offset on desktop)
  useEffect(() => {
    if (reducedMotion) return;

    const handleMouseMove = (e: MouseEvent) => {
      if (!mascotRef.current) return;
      const rect = mascotRef.current.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;

      const deltaX = e.clientX - centerX;
      const deltaY = e.clientY - centerY;
      const distance = Math.hypot(deltaX, deltaY);

      if (distance === 0) {
        setEyeOffset({ x: 0, y: 0 });
        return;
      }

      // Max 4px offset
      const maxDist = 4;
      const clampedDist = Math.min(distance / 80, maxDist);
      const normX = (deltaX / distance) * clampedDist;
      const normY = (deltaY / distance) * clampedDist;

      setEyeOffset({ x: normX, y: normY });
    };

    window.addEventListener("mousemove", handleMouseMove, { passive: true });
    return () => window.removeEventListener("mousemove", handleMouseMove);
  }, [reducedMotion]);

  return (
    <motion.div
      ref={mascotRef}
      className={`inline-block select-none cursor-pointer ${className}`}
      onClick={onClick}
      whileHover={
        interactive && !reducedMotion
          ? {
              scale: 1.08,
              y: -8,
              rotate: [0, -3, 3, 0],
              transition: { duration: 0.35, ease: "easeOut" },
            }
          : undefined
      }
      whileTap={interactive ? { scale: 0.92 } : undefined}
      style={{ width: size, height: size }}
      role="img"
      aria-label={`ZEST Mascot (${tint})`}
    >
      <svg
        viewBox="20 20 120 110"
        width="100%"
        height="100%"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="overflow-visible"
      >
        <defs>
          <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={colors.eyeGradient[0]} />
            <stop offset="100%" stopColor={colors.eyeGradient[1]} />
          </linearGradient>

          <filter
            id={filterId}
            filterUnits="userSpaceOnUse"
            x="0"
            y="0"
            width="160"
            height="160"
          >
            <feGaussianBlur stdDeviation="3.5" />
          </filter>
        </defs>

        {/* Soft atmospheric glow layer */}
        <g
          filter={`url(#${filterId})`}
          fill={colors.glow}
          stroke={colors.glow}
          strokeWidth="6"
          opacity="0.45"
        >
          <ellipse cx="80" cy="84" rx="42" ry="31" transform="rotate(-18 80 84)" />
          <circle cx="118" cy="71" r="8.5" />
          <circle cx="42" cy="97" r="8.5" />
        </g>

        {/* Crisp Body with white outline glow edge */}
        <g
          fill={colors.fill}
          stroke={colors.edge}
          strokeWidth="2.5"
          strokeLinejoin="round"
        >
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
          fill={colors.leaf}
          stroke="#FFFFFF"
          strokeWidth="1.5"
        />

        {/* Mascot Eyes with cursor tracking & blinking */}
        <g
          style={{
            transform: `translate(${eyeOffset.x}px, ${eyeOffset.y}px)`,
            transition: "transform 0.08s ease-out",
          }}
        >
          {/* Left Eye */}
          <ellipse
            cx="68"
            cy="85"
            rx="6.5"
            ry={isBlinking ? 0.7 : 10}
            transform="rotate(-8 68 85)"
            fill={`url(#${gradientId})`}
            stroke="#0B1220"
            strokeWidth="0.8"
            style={{
              transition: "ry 0.08s ease-in-out",
              transformOrigin: "68px 85px",
            }}
          />
          {/* Left Eye Pupil / Reflection */}
          {!isBlinking && (
            <circle
              cx={68 + (eyeOffset.x > 0 ? 1.5 : -1)}
              cy={83 + (eyeOffset.y > 0 ? 1.5 : -1)}
              r="2.2"
              fill="#0B1220"
            />
          )}

          {/* Right Eye */}
          <ellipse
            cx="93"
            cy="79"
            rx="6.5"
            ry={isBlinking ? 0.7 : 10}
            transform="rotate(-8 93 79)"
            fill={`url(#${gradientId})`}
            stroke="#0B1220"
            strokeWidth="0.8"
            style={{
              transition: "ry 0.08s ease-in-out",
              transformOrigin: "93px 79px",
            }}
          />
          {/* Right Eye Pupil / Reflection */}
          {!isBlinking && (
            <circle
              cx={93 + (eyeOffset.x > 0 ? 1.5 : -1)}
              cy={77 + (eyeOffset.y > 0 ? 1.5 : -1)}
              r="2.2"
              fill="#0B1220"
            />
          )}
        </g>
      </svg>
    </motion.div>
  );
}

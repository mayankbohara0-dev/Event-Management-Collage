"use client";

import React, { ReactNode } from "react";
import { motion, useReducedMotion } from "framer-motion";

export type MeshRecipe = "sky" | "sunset" | "violet" | "mint";

interface MeshCardProps {
  recipe?: MeshRecipe;
  children: ReactNode;
  className?: string;
  enableTilt?: boolean;
}

export default function MeshCard({
  recipe = "sky",
  children,
  className = "",
  enableTilt = false,
}: MeshCardProps) {
  const reducedMotion = useReducedMotion();

  // Recipe specific background base & blob colors
  const recipes = {
    sky: {
      base: "from-[#0063F0] via-[#0AA5F0] to-[#38BDF8]",
      blobs: [
        { color: "bg-[#6CE3FF]", size: "w-72 h-72", top: "-10%", left: "-10%", anim: "animate-mesh-1" },
        { color: "bg-[#FFFFFF]", size: "w-56 h-56", top: "40%", right: "-10%", anim: "animate-mesh-2", opacity: "opacity-40" },
        { color: "bg-[#0AA5F0]", size: "w-64 h-64", bottom: "-15%", left: "20%", anim: "animate-mesh-3" },
      ],
    },
    sunset: {
      base: "from-[#0050C8] via-[#0063F0] to-[#FF6B8A]",
      blobs: [
        { color: "bg-[#FF6B8A]", size: "w-72 h-72", top: "-10%", right: "-10%", anim: "animate-mesh-1", opacity: "opacity-60" },
        { color: "bg-[#FFD84D]", size: "w-64 h-64", bottom: "-10%", left: "-5%", anim: "animate-mesh-2", opacity: "opacity-55" },
        { color: "bg-[#38BDF8]", size: "w-56 h-56", top: "30%", left: "25%", anim: "animate-mesh-3", opacity: "opacity-50" },
      ],
    },
    violet: {
      base: "from-[#0050C8] via-[#4F46E5] to-[#8E8BEA]",
      blobs: [
        { color: "bg-[#8E8BEA]", size: "w-72 h-72", top: "-15%", left: "-5%", anim: "animate-mesh-1", opacity: "opacity-65" },
        { color: "bg-[#6CE3FF]", size: "w-64 h-64", bottom: "-10%", right: "-10%", anim: "animate-mesh-2", opacity: "opacity-50" },
        { color: "bg-[#38BDF8]", size: "w-52 h-52", top: "35%", right: "20%", anim: "animate-mesh-3", opacity: "opacity-45" },
      ],
    },
    mint: {
      base: "from-[#0050C8] via-[#0AA5F0] to-[#3DDC97]",
      blobs: [
        { color: "bg-[#3DDC97]", size: "w-72 h-72", top: "-10%", left: "-10%", anim: "animate-mesh-1", opacity: "opacity-55" },
        { color: "bg-[#FFD84D]", size: "w-60 h-60", bottom: "-15%", right: "-5%", anim: "animate-mesh-2", opacity: "opacity-50" },
        { color: "bg-[#6CE3FF]", size: "w-64 h-64", top: "30%", left: "30%", anim: "animate-mesh-3", opacity: "opacity-45" },
      ],
    },
  };

  const current = recipes[recipe] || recipes.sky;

  return (
    <div
      className={`relative overflow-hidden rounded-[32px] bg-gradient-to-br ${current.base} text-white shadow-[0_10px_40px_rgba(11,18,32,0.08)] border border-white/20 transition-all duration-300 ${className}`}
    >
      {/* Drifting blurred blobs (blur 60-90px) */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden select-none">
        {current.blobs.map((blob, idx) => (
          <div
            key={idx}
            className={`absolute rounded-full blur-[75px] ${blob.color} ${blob.size} ${blob.opacity || "opacity-50"} ${
              reducedMotion ? "" : blob.anim
            }`}
            style={{
              top: blob.top,
              left: blob.left,
              right: blob.right,
              bottom: blob.bottom,
            }}
          />
        ))}
        {/* Subtle glass grain/light sheen */}
        <div className="absolute inset-0 bg-white/[0.04] backdrop-blur-[1px]" />
      </div>

      {/* Content wrapper */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}

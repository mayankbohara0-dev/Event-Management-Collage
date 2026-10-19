"use client";

import React, { useRef, useState, ReactNode } from "react";
import { motion, useReducedMotion } from "framer-motion";

interface MagneticButtonProps {
  children: ReactNode;
  variant?: "primary" | "secondary" | "dark";
  className?: string;
  onClick?: () => void;
  href?: string;
  ariaLabel?: string;
}

export default function MagneticButton({
  children,
  variant = "primary",
  className = "",
  onClick,
  href,
  ariaLabel,
}: MagneticButtonProps) {
  const buttonRef = useRef<HTMLDivElement>(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const reducedMotion = useReducedMotion();

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (reducedMotion || !buttonRef.current) return;
    const { clientX, clientY } = e;
    const { left, top, width, height } = buttonRef.current.getBoundingClientRect();
    const centerX = left + width / 2;
    const centerY = top + height / 2;

    // Shift up to 6px toward cursor
    const deltaX = (clientX - centerX) * 0.15;
    const deltaY = (clientY - centerY) * 0.15;

    const maxShift = 6;
    const clampedX = Math.max(-maxShift, Math.min(maxShift, deltaX));
    const clampedY = Math.max(-maxShift, Math.min(maxShift, deltaY));

    setPosition({ x: clampedX, y: clampedY });
  };

  const handleMouseLeave = () => {
    setPosition({ x: 0, y: 0 });
  };

  const variantClasses = {
    primary: "btn-primary px-7 py-3.5 text-[15px] sm:text-[16px]",
    secondary: "btn-secondary px-7 py-3.5 text-[15px] sm:text-[16px]",
    dark: "btn-dark px-7 py-3.5 text-[15px] sm:text-[16px]",
  };

  const buttonContent = (
    <motion.div
      ref={buttonRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      animate={{ x: position.x, y: position.y }}
      transition={{ type: "spring", stiffness: 350, damping: 25, mass: 0.5 }}
      whileTap={{ scale: 0.97 }}
      className={`inline-flex items-center justify-center cursor-pointer select-none transition-all ${variantClasses[variant]} ${className}`}
      role={href ? undefined : "button"}
      aria-label={ariaLabel}
      onClick={onClick}
    >
      {children}
    </motion.div>
  );

  if (href) {
    return (
      <a href={href} className="inline-block no-underline">
        {buttonContent}
      </a>
    );
  }

  return buttonContent;
}

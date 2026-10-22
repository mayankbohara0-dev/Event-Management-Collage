"use client";

import React from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

interface SwitchProps {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
  id?: string;
  className?: string;
  label?: string;
  description?: string;
}

export function Switch({
  checked,
  onCheckedChange,
  disabled = false,
  id,
  className,
  label,
  description,
}: SwitchProps) {
  return (
    <div className={cn("inline-flex items-center gap-3", className)}>
      <button
        id={id}
        role="switch"
        type="button"
        aria-checked={checked}
        disabled={disabled}
        onClick={() => !disabled && onCheckedChange(!checked)}
        className={cn(
          "relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full p-0.5 transition-colors duration-fast focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-core focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
          checked ? "bg-brand-gradient" : "bg-line hover:bg-line/80"
        )}
      >
        <motion.span
          className="pointer-events-none block h-5 w-5 rounded-full bg-white shadow-sm"
          animate={{ x: checked ? 20 : 0 }}
          transition={{ type: "spring", stiffness: 500, damping: 30 }}
        />
      </button>

      {(label || description) && (
        <div className="flex flex-col select-none">
          {label && (
            <label
              htmlFor={id}
              className="text-sm font-medium text-ink cursor-pointer"
            >
              {label}
            </label>
          )}
          {description && (
            <span className="text-xs text-ink-3">{description}</span>
          )}
        </div>
      )}
    </div>
  );
}

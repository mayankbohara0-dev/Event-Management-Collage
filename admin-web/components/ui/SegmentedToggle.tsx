"use client";

import React, { useId } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

export interface SegmentedOption<T extends string = string> {
  value: T;
  label: React.ReactNode;
  icon?: React.ReactNode;
  count?: number;
}

interface SegmentedToggleProps<T extends string = string> {
  options: SegmentedOption<T>[];
  value: T;
  onChange: (value: T) => void;
  className?: string;
  size?: "sm" | "md";
}

export function SegmentedToggle<T extends string = string>({
  options,
  value,
  onChange,
  className,
  size = "md",
}: SegmentedToggleProps<T>) {
  const layoutId = useId();

  return (
    <div
      className={cn(
        "relative inline-flex items-center p-1 bg-fill rounded-pill border border-line select-none",
        size === "sm" ? "h-8" : "h-10",
        className
      )}
    >
      {options.map((option) => {
        const isSelected = option.value === value;
        return (
          <button
            key={option.value}
            type="button"
            onClick={() => onChange(option.value)}
            className={cn(
              "relative z-10 flex items-center justify-center font-medium rounded-pill transition-colors duration-fast",
              size === "sm" ? "px-3 text-xs" : "px-4 text-sm",
              isSelected ? "text-ink font-semibold" : "text-ink-2 hover:text-ink"
            )}
          >
            {isSelected && (
              <motion.div
                layoutId={`segmented-thumb-${layoutId}`}
                className="absolute inset-0 bg-card rounded-pill shadow-sm border border-line/60"
                transition={{ type: "spring", stiffness: 450, damping: 32 }}
              />
            )}
            <span className="relative z-20 flex items-center gap-1.5">
              {option.icon && <span className="shrink-0">{option.icon}</span>}
              <span>{option.label}</span>
              {typeof option.count === "number" && (
                <span
                  className={cn(
                    "text-[10px] px-1.5 py-0.2 rounded-full font-mono",
                    isSelected
                      ? "bg-brand-tint text-brand-blue"
                      : "bg-line text-ink-3"
                  )}
                >
                  {option.count}
                </span>
              )}
            </span>
          </button>
        );
      })}
    </div>
  );
}

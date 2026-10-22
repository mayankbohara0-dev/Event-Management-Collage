"use client";

import React from "react";
import { cn } from "@/lib/utils";

interface ProgressBarProps {
  value: number; // 0 to 100 or current count
  max?: number;
  variant?: "brand" | "success" | "warning" | "danger";
  size?: "sm" | "md" | "lg";
  showLabel?: boolean;
  className?: string;
}

export function ProgressBar({
  value,
  max = 100,
  variant = "brand",
  size = "md",
  showLabel = false,
  className,
}: ProgressBarProps) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  const sizeStyles = {
    sm: "h-1.5",
    md: "h-2.5",
    lg: "h-4",
  };

  const variantStyles = {
    brand: "bg-brand-gradient",
    success: "bg-semantic-success",
    warning: "bg-semantic-warning",
    danger: "bg-semantic-danger",
  };

  // Auto switch to warning/danger if fill is > 85% / 95%
  const activeVariant =
    variant === "brand"
      ? percentage >= 95
        ? "danger"
        : percentage >= 85
        ? "warning"
        : "brand"
      : variant;

  return (
    <div className={cn("w-full", className)}>
      {showLabel && (
        <div className="flex justify-between items-center text-xs text-ink-2 mb-1.5 font-medium tabular-nums">
          <span>{Math.round(percentage)}% capacity</span>
          <span>
            {value} / {max}
          </span>
        </div>
      )}
      <div className={cn("w-full bg-fill rounded-full overflow-hidden p-0.5 border border-line/40", sizeStyles[size])}>
        <div
          className={cn("h-full rounded-full transition-all duration-500 ease-out", variantStyles[activeVariant])}
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  );
}

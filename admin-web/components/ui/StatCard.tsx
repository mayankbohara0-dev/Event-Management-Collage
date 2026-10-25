"use client";

import React, { useEffect, useState } from "react";
import { ArrowUpRight, ArrowDownRight, Minus } from "lucide-react";
import { cn } from "@/lib/utils";
import { Card } from "./Card";

export interface StatCardProps {
  title?: string;
  label?: string;
  value: number | string;
  delta?: {
    value: number; // e.g., 14.5%
    label?: string; // "vs last month"
  };
  subtitle?: string;
  sub?: string;
  icon?: React.ReactNode;
  color?: string;
  variant?: "default" | "brand";
  className?: string;
}

export function StatCard({
  title,
  label,
  value,
  delta,
  subtitle,
  sub,
  icon,
  color,
  variant = "default",
  className,
}: StatCardProps) {
  const cardTitle = title || label || "";
  const cardSubtitle = subtitle || sub;
  const isBrand = variant === "brand";

  // Formatted count-up animation for numeric values
  const [displayValue, setDisplayValue] = useState<number | string>(value);

  useEffect(() => {
    if (typeof value !== "number" || value <= 5) {
      setDisplayValue(value);
      return;
    }

    const duration = 240; // ms
    const steps = 8;
    const stepDuration = duration / steps;
    let step = 0;

    const timer = setInterval(() => {
      step++;
      const progress = step / steps;
      const easeOut = 1 - Math.pow(1 - progress, 3);
      const current = Math.round(value * easeOut);

      setDisplayValue(current);

      if (step >= steps) {
        clearInterval(timer);
        setDisplayValue(value);
      }
    }, stepDuration);

    return () => clearInterval(timer);
  }, [value]);

  return (
    <Card
      variant={isBrand ? "brand" : "default"}
      className={cn("p-6 flex flex-col justify-between relative overflow-hidden", className)}
    >
      <div className="flex items-center justify-between gap-3 mb-3">
        <span
          className={cn(
            "text-xs font-semibold uppercase tracking-wider",
            isBrand ? "text-white/80" : "text-ink-2"
          )}
        >
          {cardTitle}
        </span>
        {icon && (
          <div
            className={cn(
              "w-8 h-8 rounded-full flex items-center justify-center shrink-0",
              isBrand ? "bg-white/20 text-white" : "bg-fill text-brand-core"
            )}
          >
            {icon}
          </div>
        )}
      </div>

      <div className="flex items-baseline gap-3 my-1">
        <span
          className={cn(
            "text-3xl lg:text-4xl font-bold tracking-tight font-sans tabular-nums",
            isBrand ? "text-white" : "text-ink"
          )}
        >
          {typeof displayValue === "number"
            ? displayValue.toLocaleString()
            : displayValue}
        </span>

        {delta && (
          <span
            className={cn(
              "inline-flex items-center gap-0.5 text-xs font-semibold px-2 py-0.5 rounded-pill tabular-nums",
              isBrand
                ? "bg-white/20 text-white"
                : delta.value > 0
                ? "bg-semantic-success-tint text-semantic-success"
                : delta.value < 0
                ? "bg-semantic-danger-tint text-semantic-danger"
                : "bg-fill text-ink-3"
            )}
          >
            {delta.value > 0 ? (
              <ArrowUpRight size={13} strokeWidth={2.5} />
            ) : delta.value < 0 ? (
              <ArrowDownRight size={13} strokeWidth={2.5} />
            ) : (
              <Minus size={13} />
            )}
            {Math.abs(delta.value)}%
          </span>
        )}
      </div>

      {(cardSubtitle || delta?.label) && (
        <p
          className={cn(
            "text-xs mt-2 font-normal",
            isBrand ? "text-white/70" : "text-ink-3"
          )}
        >
          {cardSubtitle || delta?.label}
        </p>
      )}
    </Card>
  );
}

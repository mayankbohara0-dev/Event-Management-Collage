"use client";

import React from "react";
import { Check } from "lucide-react";
import { cn } from "@/lib/utils";

interface CheckboxProps {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
  id?: string;
  className?: string;
  label?: React.ReactNode;
}

export function Checkbox({
  checked,
  onCheckedChange,
  disabled = false,
  id,
  className,
  label,
}: CheckboxProps) {
  return (
    <label
      className={cn(
        "inline-flex items-center gap-2.5 cursor-pointer select-none",
        disabled && "opacity-50 cursor-not-allowed",
        className
      )}
    >
      <div
        role="checkbox"
        aria-checked={checked}
        tabIndex={disabled ? -1 : 0}
        onKeyDown={(e) => {
          if (e.key === " " || e.key === "Enter") {
            e.preventDefault();
            if (!disabled) onCheckedChange(!checked);
          }
        }}
        onClick={(e) => {
          e.stopPropagation();
          if (!disabled) onCheckedChange(!checked);
        }}
        className={cn(
          "h-5 w-5 rounded-md border flex items-center justify-center transition-all duration-fast focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-core focus-visible:ring-offset-1",
          checked
            ? "bg-brand-core border-brand-core text-white"
            : "border-line bg-card hover:border-ink-3/40"
        )}
      >
        {checked && <Check size={13} strokeWidth={3} />}
      </div>
      {label && <span className="text-sm text-ink">{label}</span>}
    </label>
  );
}

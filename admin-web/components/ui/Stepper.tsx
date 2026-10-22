"use client";

import React from "react";
import { Plus, Minus } from "lucide-react";
import { cn } from "@/lib/utils";

interface StepperProps {
  value: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
  step?: number;
  presets?: number[];
  className?: string;
  label?: string;
}

export function Stepper({
  value,
  onChange,
  min = 1,
  max = 10000,
  step = 10,
  presets = [50, 100, 250, 500],
  className,
  label,
}: StepperProps) {
  const handleDecrement = () => {
    onChange(Math.max(min, value - step));
  };

  const handleIncrement = () => {
    onChange(Math.min(max, value + step));
  };

  return (
    <div className={cn("space-y-3", className)}>
      {label && <label className="block text-sm font-medium text-ink">{label}</label>}
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={handleDecrement}
          disabled={value <= min}
          className="w-10 h-10 rounded-input bg-card border border-line flex items-center justify-center text-ink hover:bg-fill hover:border-ink-3/40 active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed transition-all"
        >
          <Minus size={16} />
        </button>

        <input
          type="number"
          value={value}
          min={min}
          max={max}
          onChange={(e) => {
            const val = parseInt(e.target.value, 10);
            if (!isNaN(val)) onChange(Math.max(min, Math.min(max, val)));
          }}
          className="w-24 h-10 text-center font-bold text-ink rounded-input bg-card border border-line focus:outline-none focus:border-brand-core focus:ring-2 focus:ring-brand-core/20 tabular-nums"
        />

        <button
          type="button"
          onClick={handleIncrement}
          disabled={value >= max}
          className="w-10 h-10 rounded-input bg-card border border-line flex items-center justify-center text-ink hover:bg-fill hover:border-ink-3/40 active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed transition-all"
        >
          <Plus size={16} />
        </button>
      </div>

      {presets && presets.length > 0 && (
        <div className="flex items-center gap-1.5 pt-1">
          <span className="text-xs text-ink-3 mr-1">Presets:</span>
          {presets.map((preset) => (
            <button
              key={preset}
              type="button"
              onClick={() => onChange(preset)}
              className={cn(
                "text-xs px-2.5 py-1 rounded-pill border font-medium transition-all",
                value === preset
                  ? "bg-brand-core text-white border-brand-core"
                  : "bg-fill border-line text-ink-2 hover:text-ink hover:border-ink-3/40"
              )}
            >
              {preset}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

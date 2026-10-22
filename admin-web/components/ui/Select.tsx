"use client";

import React from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";

export interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  error?: string;
  helperText?: string;
}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, error, helperText, children, ...props }, ref) => {
    return (
      <div className="w-full">
        <div className="relative flex items-center w-full">
          <select
            ref={ref}
            className={cn(
              "w-full h-11 px-3.5 pr-10 py-2.5 bg-card text-ink text-sm rounded-input border border-line transition-all duration-fast appearance-none cursor-pointer",
              "focus:outline-none focus:border-brand-core focus:ring-2 focus:ring-brand-core/20",
              "disabled:bg-fill disabled:text-ink-3 disabled:cursor-not-allowed",
              error && "border-semantic-danger focus:border-semantic-danger focus:ring-semantic-danger/20",
              className
            )}
            {...props}
          >
            {children}
          </select>
          <div className="absolute right-3.5 pointer-events-none text-ink-3 flex items-center">
            <ChevronDown size={16} />
          </div>
        </div>
        {error ? (
          <p className="mt-1.5 text-xs text-semantic-danger font-medium">{error}</p>
        ) : helperText ? (
          <p className="mt-1.5 text-xs text-ink-3">{helperText}</p>
        ) : null}
      </div>
    );
  }
);

Select.displayName = "Select";

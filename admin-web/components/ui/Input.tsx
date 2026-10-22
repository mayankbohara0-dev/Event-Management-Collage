"use client";

import React from "react";
import { cn } from "@/lib/utils";

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  helperText?: string;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, error, leftIcon, rightIcon, helperText, type = "text", ...props }, ref) => {
    return (
      <div className="w-full">
        <div className="relative flex items-center w-full">
          {leftIcon && (
            <div className="absolute left-3.5 text-ink-3 pointer-events-none flex items-center">
              {leftIcon}
            </div>
          )}
          <input
            ref={ref}
            type={type}
            className={cn(
              "w-full h-11 px-3.5 py-2.5 bg-card text-ink text-sm rounded-input border border-line placeholder:text-ink-3/70 transition-all duration-fast",
              "focus:outline-none focus:border-brand-core focus:ring-2 focus:ring-brand-core/20",
              "disabled:bg-fill disabled:text-ink-3 disabled:cursor-not-allowed",
              leftIcon && "pl-10",
              rightIcon && "pr-10",
              error && "border-semantic-danger focus:border-semantic-danger focus:ring-semantic-danger/20",
              className
            )}
            {...props}
          />
          {rightIcon && (
            <div className="absolute right-3.5 text-ink-3 flex items-center">
              {rightIcon}
            </div>
          )}
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

Input.displayName = "Input";

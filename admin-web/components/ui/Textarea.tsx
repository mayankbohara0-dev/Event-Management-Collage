"use client";

import React from "react";
import { cn } from "@/lib/utils";

export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  error?: string;
  helperText?: string;
}

export const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, error, helperText, rows = 4, ...props }, ref) => {
    return (
      <div className="w-full">
        <textarea
          ref={ref}
          rows={rows}
          className={cn(
            "w-full px-3.5 py-2.5 bg-card text-ink text-sm rounded-input border border-line placeholder:text-ink-3/70 transition-all duration-fast resize-y",
            "focus:outline-none focus:border-brand-core focus:ring-2 focus:ring-brand-core/20",
            "disabled:bg-fill disabled:text-ink-3 disabled:cursor-not-allowed",
            error && "border-semantic-danger focus:border-semantic-danger focus:ring-semantic-danger/20",
            className
          )}
          {...props}
        />
        {error ? (
          <p className="mt-1.5 text-xs text-semantic-danger font-medium">{error}</p>
        ) : helperText ? (
          <p className="mt-1.5 text-xs text-ink-3">{helperText}</p>
        ) : null}
      </div>
    );
  }
);

Textarea.displayName = "Textarea";

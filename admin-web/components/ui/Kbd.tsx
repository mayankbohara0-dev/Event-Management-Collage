"use client";

import React from "react";
import { cn } from "@/lib/utils";

interface KbdProps extends React.HTMLAttributes<HTMLElement> {
  className?: string;
}

export function Kbd({ className, children, ...props }: KbdProps) {
  return (
    <kbd
      className={cn(
        "inline-flex items-center justify-center font-mono text-[11px] font-semibold text-ink-3 bg-fill border border-line rounded px-1.5 py-0.5 shadow-sm select-none",
        className
      )}
      {...props}
    >
      {children}
    </kbd>
  );
}

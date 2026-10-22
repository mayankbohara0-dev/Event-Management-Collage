"use client";

import React from "react";
import { cn } from "@/lib/utils";
import { Mascot, MascotMood, MascotTint } from "@/components/brand/Mascot";

interface EmptyStateProps {
  title: React.ReactNode;
  description?: React.ReactNode;
  action?: React.ReactNode;
  icon?: React.ReactNode;
  mood?: MascotMood;
  tint?: MascotTint;
  className?: string;
}

export function EmptyState({
  title,
  description,
  action,
  icon,
  mood = "sleepy",
  tint = "blue",
  className,
}: EmptyStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center text-center p-10 bg-card rounded-card border border-dashed border-line",
        className
      )}
    >
      <div className="w-24 h-24 mb-4 flex items-center justify-center">
        {icon ? (
          <div className="w-16 h-16 rounded-full bg-fill text-brand-core flex items-center justify-center">
            {icon}
          </div>
        ) : (
          <Mascot size={84} mood={mood} tint={tint} />
        )}
      </div>

      <h3 className="text-lg font-semibold text-ink tracking-tight mb-1">
        {title}
      </h3>

      {description && (
        <p className="text-sm text-ink-2 max-w-md mb-6">{description}</p>
      )}

      {action && <div className="mt-1">{action}</div>}
    </div>
  );
}

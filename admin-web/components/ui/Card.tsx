"use client";

import React from "react";
import { cn } from "@/lib/utils";

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: "default" | "hero" | "subtle" | "brand";
  hoverEffect?: boolean;
}

export function Card({
  className,
  variant = "default",
  hoverEffect = false,
  children,
  ...props
}: CardProps) {
  const variantStyles = {
    default: "bg-card border border-line text-ink rounded-card",
    hero: "bg-card border border-line text-ink rounded-hero shadow-sm",
    subtle: "bg-fill/60 border border-line/80 text-ink rounded-card",
    brand: "bg-brand-gradient text-white border-0 rounded-card shadow-sm",
  };

  return (
    <div
      className={cn(
        "p-6 relative transition-all duration-fast",
        variantStyles[variant],
        hoverEffect && "hover:-translate-y-0.5 hover:shadow-floating",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}

interface SectionCardProps extends Omit<CardProps, "title"> {
  title?: React.ReactNode;
  description?: React.ReactNode;
  action?: React.ReactNode;
  headerClassName?: string;
  bodyClassName?: string;
}

export function SectionCard({
  title,
  description,
  action,
  headerClassName,
  bodyClassName,
  children,
  className,
  ...props
}: SectionCardProps) {
  return (
    <Card className={cn("overflow-hidden", className)} {...props}>
      {(title || description || action) && (
        <div
          className={cn(
            "flex items-start justify-between gap-4 mb-5 pb-4 border-b border-line/60",
            headerClassName
          )}
        >
          <div>
            {title && (
              <h3 className="text-base font-semibold text-ink tracking-tight">
                {title}
              </h3>
            )}
            {description && (
              <p className="text-xs text-ink-2 mt-0.5">{description}</p>
            )}
          </div>
          {action && <div className="shrink-0">{action}</div>}
        </div>
      )}
      <div className={bodyClassName}>{children}</div>
    </Card>
  );
}

"use client";

import React from "react";
import { cn } from "@/lib/utils";

export type BadgeVariant =
  | "default"
  | "brand"
  | "success"
  | "warning"
  | "danger"
  | "lemon"
  | "coral"
  | "aqua"
  | "lavender"
  | "mint";

interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: BadgeVariant;
  size?: "sm" | "md";
  dot?: boolean;
}

export function Badge({
  className,
  variant = "default",
  size = "md",
  dot = false,
  children,
  ...props
}: BadgeProps) {
  const variantStyles: Record<BadgeVariant, { container: string; dot: string }> = {
    default: {
      container: "bg-fill text-ink border-line",
      dot: "bg-ink-3",
    },
    brand: {
      container: "bg-brand-tint text-brand-blue border-brand-core/20",
      dot: "bg-brand-core",
    },
    success: {
      container: "bg-semantic-success-tint text-semantic-success border-semantic-success/20",
      dot: "bg-semantic-success",
    },
    warning: {
      container: "bg-semantic-warning-tint text-semantic-warning border-semantic-warning/20",
      dot: "bg-semantic-warning",
    },
    danger: {
      container: "bg-semantic-danger-tint text-semantic-danger border-semantic-danger/20",
      dot: "bg-semantic-danger",
    },
    lemon: {
      container: "bg-[#FEF9C3] text-[#A16207] border-[#FDE047]/40",
      dot: "bg-[#CA8A04]",
    },
    coral: {
      container: "bg-[#FFE4E6] text-[#BE123C] border-[#FDA4AF]/40",
      dot: "bg-[#E11D48]",
    },
    aqua: {
      container: "bg-[#E0F2FE] text-[#0369A1] border-[#7DD3FC]/40",
      dot: "bg-[#0284C7]",
    },
    lavender: {
      container: "bg-[#EDE9FE] text-[#6D28D9] border-[#C4B5FD]/40",
      dot: "bg-[#7C3AED]",
    },
    mint: {
      container: "bg-[#DCFCE7] text-[#15803D] border-[#86EFAC]/40",
      dot: "bg-[#16A34A]",
    },
  };

  return (
    <span
      className={cn(
        "inline-flex items-center font-medium rounded-pill border select-none",
        size === "sm" ? "px-2 py-0.5 text-[11px] gap-1" : "px-2.5 py-1 text-xs gap-1.5",
        variantStyles[variant].container,
        className
      )}
      {...props}
    >
      {dot && (
        <span
          className={cn(
            "rounded-full shrink-0",
            size === "sm" ? "w-1.5 h-1.5" : "w-2 h-2",
            variantStyles[variant].dot
          )}
        />
      )}
      {children}
    </span>
  );
}

export type StatusType =
  | "draft"
  | "published"
  | "archived"
  | "pending"
  | "approved"
  | "rejected"
  | "waitlisted"
  | "attended"
  | "not_attended";

interface StatusPillProps {
  status: StatusType | string;
  className?: string;
  size?: "sm" | "md";
}

export function StatusPill({ status, className, size = "md" }: StatusPillProps) {
  const norm = status?.toLowerCase();

  switch (norm) {
    case "published":
      return (
        <Badge variant="success" dot size={size} className={className}>
          Published
        </Badge>
      );
    case "draft":
      return (
        <Badge variant="default" dot size={size} className={className}>
          Draft
        </Badge>
      );
    case "approved":
      return (
        <Badge variant="success" dot size={size} className={className}>
          Approved
        </Badge>
      );
    case "pending":
      return (
        <Badge variant="warning" dot size={size} className={className}>
          Pending
        </Badge>
      );
    case "rejected":
      return (
        <Badge variant="danger" dot size={size} className={className}>
          Rejected
        </Badge>
      );
    case "waitlisted":
      return (
        <Badge variant="lavender" dot size={size} className={className}>
          Waitlisted
        </Badge>
      );
    case "attended":
      return (
        <Badge variant="brand" dot size={size} className={className}>
          Attended
        </Badge>
      );
    case "not_attended":
      return (
        <Badge variant="default" dot size={size} className={className}>
          Not Attended
        </Badge>
      );
    default:
      return (
        <Badge variant="default" size={size} className={className}>
          {status}
        </Badge>
      );
  }
}

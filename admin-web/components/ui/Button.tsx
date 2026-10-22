"use client";

import React from "react";
import { motion, HTMLMotionProps } from "framer-motion";
import { cn } from "@/lib/utils";

export type ButtonVariant = "primary" | "secondary" | "ghost" | "danger" | "outline";
export type ButtonSize = "sm" | "md" | "lg" | "icon";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  fullWidth?: boolean;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = "primary",
      size = "md",
      isLoading = false,
      leftIcon,
      rightIcon,
      fullWidth = false,
      children,
      disabled,
      ...props
    },
    ref
  ) => {
    const baseStyles =
      "inline-flex items-center justify-center font-medium rounded-pill transition-all duration-fast select-none outline-none focus-visible:ring-2 focus-visible:ring-brand-core focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none active:scale-[0.97]";

    const variantStyles: Record<ButtonVariant, string> = {
      primary:
        "bg-brand-gradient text-white shadow-hairline shadow-brand-blue/20 hover:shadow-floating hover:brightness-105 active:brightness-95",
      secondary:
        "bg-fill text-ink border border-line hover:bg-line/70 hover:border-ink-3/40",
      ghost:
        "bg-transparent text-ink-2 hover:text-ink hover:bg-fill/80",
      danger:
        "bg-semantic-danger text-white hover:bg-semantic-danger/90 shadow-sm",
      outline:
        "bg-card text-ink border border-line hover:border-brand-core hover:bg-brand-tint/30",
    };

    const sizeStyles: Record<ButtonSize, string> = {
      sm: "text-xs px-3.5 py-1.5 h-8 gap-1.5",
      md: "text-sm px-5 py-2.5 h-10 gap-2",
      lg: "text-base px-6 py-3.5 h-12 gap-2.5",
      icon: "h-10 w-10 p-0",
    };

    return (
      <button
        ref={ref}
        disabled={disabled || isLoading}
        className={cn(
          baseStyles,
          variantStyles[variant],
          sizeStyles[size],
          fullWidth && "w-full",
          className
        )}
        {...props}
      >
        {isLoading ? (
          <div className="flex items-center gap-1.5 py-1">
            <span className="w-1.5 h-1.5 rounded-full bg-current animate-bounce [animation-delay:-0.3s]" />
            <span className="w-1.5 h-1.5 rounded-full bg-current animate-bounce [animation-delay:-0.15s]" />
            <span className="w-1.5 h-1.5 rounded-full bg-current animate-bounce" />
          </div>
        ) : (
          <>
            {leftIcon && <span className="shrink-0">{leftIcon}</span>}
            {children}
            {rightIcon && <span className="shrink-0">{rightIcon}</span>}
          </>
        )}
      </button>
    );
  }
);

Button.displayName = "Button";

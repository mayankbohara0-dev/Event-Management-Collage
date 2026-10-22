"use client";

import React, { useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";
import { cn } from "@/lib/utils";

interface DrawerProps {
  isOpen: boolean;
  onClose: () => void;
  title?: React.ReactNode;
  description?: React.ReactNode;
  children: React.ReactNode;
  footer?: React.ReactNode;
  width?: string;
  className?: string;
}

export function Drawer({
  isOpen,
  onClose,
  title,
  description,
  children,
  footer,
  width = "max-w-[480px]",
  className,
}: DrawerProps) {
  // ESC key listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isOpen) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  // Prevent background scroll
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex justify-end">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            onClick={onClose}
            className="fixed inset-0 bg-ink/30 backdrop-blur-sm"
          />

          {/* Drawer Sheet */}
          <motion.div
            initial={{ x: "100%" }}
            animate={{ x: 0 }}
            exit={{ x: "100%" }}
            transition={{ type: "spring", stiffness: 380, damping: 36 }}
            className={cn(
              "relative z-10 w-full h-full bg-card shadow-floating border-l border-line flex flex-col justify-between overflow-hidden",
              width,
              className
            )}
          >
            {/* Header */}
            <div className="flex items-start justify-between p-6 border-b border-line/70 shrink-0">
              <div>
                {title && (
                  <h2 className="text-xl font-semibold text-ink tracking-tight">
                    {title}
                  </h2>
                )}
                {description && (
                  <p className="text-xs text-ink-2 mt-1">{description}</p>
                )}
              </div>
              <button
                type="button"
                onClick={onClose}
                className="w-8 h-8 rounded-full flex items-center justify-center text-ink-3 hover:text-ink hover:bg-fill transition-colors"
                aria-label="Close drawer"
              >
                <X size={18} />
              </button>
            </div>

            {/* Scrollable Body */}
            <div className="p-6 overflow-y-auto flex-1">{children}</div>

            {/* Footer */}
            {footer && (
              <div className="p-5 border-t border-line/70 bg-page/50 shrink-0">
                {footer}
              </div>
            )}
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}

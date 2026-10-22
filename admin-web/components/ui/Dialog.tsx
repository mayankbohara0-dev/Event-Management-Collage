"use client";

import React, { useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";
import { cn } from "@/lib/utils";
import { Mascot, MascotMood } from "@/components/brand/Mascot";
import { Button } from "./Button";

interface DialogProps {
  isOpen: boolean;
  onClose: () => void;
  title?: React.ReactNode;
  description?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
  maxWidth?: string;
}

export function Dialog({
  isOpen,
  onClose,
  title,
  description,
  children,
  className,
  maxWidth = "max-w-lg",
}: DialogProps) {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isOpen) onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

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
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.18 }}
            onClick={onClose}
            className="fixed inset-0 bg-ink/30 backdrop-blur-sm"
          />

          {/* Modal Card */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 8 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 8 }}
            transition={{ type: "spring", stiffness: 420, damping: 32 }}
            className={cn(
              "relative z-10 w-full bg-card rounded-card border border-line shadow-floating p-6 overflow-hidden",
              maxWidth,
              className
            )}
          >
            <div className="flex items-start justify-between mb-4">
              <div>
                {title && (
                  <h3 className="text-xl font-semibold text-ink tracking-tight">
                    {title}
                  </h3>
                )}
                {description && (
                  <p className="text-xs text-ink-2 mt-1">{description}</p>
                )}
              </div>
              <button
                type="button"
                onClick={onClose}
                className="w-8 h-8 rounded-full flex items-center justify-center text-ink-3 hover:text-ink hover:bg-fill transition-colors -mr-1.5 -mt-1.5"
                aria-label="Close dialog"
              >
                <X size={18} />
              </button>
            </div>

            <div>{children}</div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}

interface ConfirmDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: React.ReactNode;
  description: React.ReactNode;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: "danger" | "brand";
  mascotMood?: MascotMood;
  isLoading?: boolean;
}

export function ConfirmDialog({
  isOpen,
  onClose,
  onConfirm,
  title,
  description,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  variant = "brand",
  mascotMood = "idle",
  isLoading = false,
}: ConfirmDialogProps) {
  return (
    <Dialog isOpen={isOpen} onClose={onClose} maxWidth="max-w-md">
      <div className="flex flex-col items-center text-center pt-2 pb-1">
        <div className="w-20 h-20 mb-4 flex items-center justify-center">
          <Mascot size={76} mood={mascotMood} tint={variant === "danger" ? "coral" : "blue"} />
        </div>

        <h3 className="text-xl font-bold text-ink tracking-tight mb-2">
          {title}
        </h3>

        <div className="text-sm text-ink-2 mb-6 max-w-sm">
          {description}
        </div>

        <div className="flex items-center gap-3 w-full">
          <Button
            variant="secondary"
            fullWidth
            onClick={onClose}
            disabled={isLoading}
          >
            {cancelLabel}
          </Button>
          <Button
            variant={variant === "danger" ? "danger" : "primary"}
            fullWidth
            onClick={onConfirm}
            isLoading={isLoading}
          >
            {confirmLabel}
          </Button>
        </div>
      </div>
    </Dialog>
  );
}

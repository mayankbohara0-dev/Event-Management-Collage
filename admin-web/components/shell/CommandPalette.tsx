"use client";

import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Command } from "cmdk";
import {
  Search,
  LayoutDashboard,
  CalendarDays,
  Users,
  GraduationCap,
  ScanLine,
  BarChart3,
  Settings,
  PlusCircle,
  HelpCircle,
  Download,
} from "lucide-react";
import { Kbd } from "@/components/ui/Kbd";

interface CommandPaletteProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function CommandPalette({ open, onOpenChange }: CommandPaletteProps) {
  const router = useRouter();
  const [showHelp, setShowHelp] = useState(false);

  // Global keydown listeners for shortcuts
  useEffect(() => {
    let lastKey = "";
    let lastKeyTime = 0;

    const handleKeyDown = (e: KeyboardEvent) => {
      // Don't trigger shortcuts if focus is inside an input/textarea
      const tag = (e.target as HTMLElement)?.tagName?.toLowerCase();
      const isInput = tag === "input" || tag === "textarea" || (e.target as HTMLElement)?.isContentEditable;

      // ⌘K or Ctrl+K to toggle palette
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        onOpenChange(!open);
        return;
      }

      // / to open search
      if (e.key === "/" && !isInput) {
        e.preventDefault();
        onOpenChange(true);
        return;
      }

      // ? for shortcut help
      if (e.key === "?" && !isInput) {
        e.preventDefault();
        setShowHelp((prev) => !prev);
        return;
      }

      if (isInput) return;

      const now = Date.now();
      const currentKey = e.key.toLowerCase();

      // Two-key chord shortcuts (e.g. g then d)
      if (lastKey === "g" && now - lastKeyTime < 800) {
        if (currentKey === "d") {
          e.preventDefault();
          router.push("/dashboard");
        } else if (currentKey === "e") {
          e.preventDefault();
          router.push("/events");
        } else if (currentKey === "r") {
          e.preventDefault();
          router.push("/registrations");
        }
        lastKey = "";
        return;
      }

      if (currentKey === "c") {
        e.preventDefault();
        router.push("/events/new");
        return;
      }

      lastKey = currentKey;
      lastKeyTime = now;
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [open, onOpenChange, router]);

  const runCommand = (action: () => void) => {
    onOpenChange(false);
    action();
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-20 p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-ink/30 backdrop-blur-sm"
        onClick={() => onOpenChange(false)}
      />

      {/* Palette Container */}
      <div className="relative z-10 w-full max-w-xl bg-card rounded-card border border-line shadow-floating overflow-hidden animate-in fade-in zoom-in-95 duration-180">
        <Command className="w-full">
          <div className="flex items-center gap-3 px-4 border-b border-line">
            <Search size={18} className="text-ink-3 shrink-0" />
            <Command.Input
              placeholder="Search or jump to... (type to search)"
              className="w-full h-13 py-3.5 bg-transparent text-sm text-ink placeholder:text-ink-3/70 outline-none"
              autoFocus
            />
            <Kbd>ESC</Kbd>
          </div>

          <Command.List className="max-h-80 overflow-y-auto p-2 space-y-2">
            <Command.Empty className="p-6 text-center text-xs text-ink-3">
              No results found.
            </Command.Empty>

            {/* Quick Actions */}
            <Command.Group heading="Quick Actions" className="text-[10px] font-bold text-ink-3 px-2 uppercase tracking-wider">
              <Command.Item
                onSelect={() => runCommand(() => router.push("/events/new"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <PlusCircle size={16} className="text-brand-core" />
                  <span>Create new event</span>
                </div>
                <Kbd>C</Kbd>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/checkin"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <ScanLine size={16} className="text-brand-blue" />
                  <span>Open live check-in scanner</span>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/registrations"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <Download size={16} className="text-semantic-success" />
                  <span>Export registrations</span>
                </div>
              </Command.Item>
            </Command.Group>

            {/* Navigation */}
            <Command.Group heading="Jump to Page" className="text-[10px] font-bold text-ink-3 px-2 pt-2 uppercase tracking-wider">
              <Command.Item
                onSelect={() => runCommand(() => router.push("/dashboard"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <LayoutDashboard size={16} className="text-ink-2" />
                  <span>Dashboard</span>
                </div>
                <div className="flex gap-1">
                  <Kbd>G</Kbd>
                  <Kbd>D</Kbd>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/events"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <CalendarDays size={16} className="text-ink-2" />
                  <span>Events list</span>
                </div>
                <div className="flex gap-1">
                  <Kbd>G</Kbd>
                  <Kbd>E</Kbd>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/registrations"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <Users size={16} className="text-ink-2" />
                  <span>Registrations</span>
                </div>
                <div className="flex gap-1">
                  <Kbd>G</Kbd>
                  <Kbd>R</Kbd>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/students"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <GraduationCap size={16} className="text-ink-2" />
                  <span>Student Directory</span>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/reports"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <BarChart3 size={16} className="text-ink-2" />
                  <span>Reports & Analytics</span>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/settings"))}
                className="flex items-center justify-between px-3 py-2 text-xs rounded-input text-ink hover:bg-fill cursor-pointer"
              >
                <div className="flex items-center gap-2.5">
                  <Settings size={16} className="text-ink-2" />
                  <span>Settings</span>
                </div>
              </Command.Item>
            </Command.Group>
          </Command.List>

          {/* Footer note */}
          <div className="p-3 border-t border-line/60 bg-page/50 flex items-center justify-between text-[11px] text-ink-3">
            <span className="flex items-center gap-1.5">
              <HelpCircle size={13} />
              <span>Use arrows to navigate, Return to select</span>
            </span>
            <span className="flex items-center gap-1">
              <span>Press</span> <Kbd>?</Kbd> <span>for shortcuts</span>
            </span>
          </div>
        </Command>
      </div>
    </div>
  );
}

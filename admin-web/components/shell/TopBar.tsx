"use client";

import React, { useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  Search,
  Plus,
  Bell,
  ChevronRight,
  Menu,
} from "lucide-react";
import { Button } from "@/components/ui/Button";
import { Kbd } from "@/components/ui/Kbd";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { CommandPalette } from "./CommandPalette";

interface TopBarProps {
  onMobileMenuToggle?: () => void;
  user?: {
    name?: string;
    avatarUrl?: string;
  };
}

export function TopBar({ onMobileMenuToggle, user }: TopBarProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [commandPaletteOpen, setCommandPaletteOpen] = useState(false);
  const [hasNewNotifications, setHasNewNotifications] = useState(false);

  // Generate breadcrumbs from pathname
  const segments = pathname.split("/").filter(Boolean);
  const breadcrumbItems = segments.map((seg, idx) => {
    const href = "/" + segments.slice(0, idx + 1).join("/");
    const formatted = seg.charAt(0).toUpperCase() + seg.slice(1).replace(/-/g, " ");
    return { href, label: formatted };
  });

  return (
    <>
      <header className="sticky top-0 z-30 h-16 bg-card/85 backdrop-blur-md border-b border-line px-4 lg:px-8 flex items-center justify-between gap-4">
        {/* Left: Mobile Menu Toggle & Breadcrumbs */}
        <div className="flex items-center gap-2.5 sm:gap-3 min-w-0">
          <button
            type="button"
            onClick={onMobileMenuToggle}
            className="lg:hidden w-9 h-9 rounded-full flex items-center justify-center text-ink-2 hover:bg-fill transition-colors shrink-0"
            aria-label="Open mobile navigation"
          >
            <Menu size={18} />
          </button>

          <Link href="/dashboard" className="lg:hidden flex items-center shrink-0">
            <BlobLogo size={26} />
          </Link>

          <nav className="flex items-center gap-1.5 text-xs font-medium text-ink-3 truncate">
            <Link
              href="/dashboard"
              className="hover:text-ink transition-colors shrink-0"
            >
              zest
            </Link>
            {breadcrumbItems.map((item, idx) => (
              <React.Fragment key={item.href}>
                <ChevronRight size={13} className="shrink-0 text-line" />
                {idx === breadcrumbItems.length - 1 ? (
                  <span className="text-ink font-semibold truncate">
                    {item.label}
                  </span>
                ) : (
                  <Link
                    href={item.href}
                    className="hover:text-ink transition-colors truncate"
                  >
                    {item.label}
                  </Link>
                )}
              </React.Fragment>
            ))}
          </nav>
        </div>

        {/* Right: Search bar, Create event button, Notifications, User */}
        <div className="flex items-center gap-2.5 sm:gap-3 shrink-0">
          {/* Global Search trigger */}
          <button
            type="button"
            onClick={() => setCommandPaletteOpen(true)}
            className="flex items-center gap-2 px-3 py-1.5 h-9 bg-fill hover:bg-line/60 text-ink-3 text-xs rounded-pill border border-line transition-all group"
          >
            <Search size={14} className="group-hover:text-ink transition-colors" />
            <span className="hidden sm:inline">Search or jump to…</span>
            <div className="flex items-center gap-0.5 ml-1">
              <Kbd>⌘</Kbd>
              <Kbd>K</Kbd>
            </div>
          </button>

          {/* Primary Create Event button */}
          <Button
            size="sm"
            onClick={() => router.push("/events/new")}
            leftIcon={<Plus size={15} strokeWidth={2.5} />}
            className="hidden sm:inline-flex"
          >
            Create event
          </Button>

          {/* Notifications bell */}
          <Link
            href="/notifications"
            className="relative w-9 h-9 rounded-full flex items-center justify-center text-ink-2 hover:text-ink hover:bg-fill transition-colors border border-transparent hover:border-line"
            title="Notifications"
          >
            <Bell size={17} />
            {hasNewNotifications && (
              <span className="absolute top-2 right-2 w-2 h-2 rounded-full bg-brand-core ring-2 ring-card animate-pulse" />
            )}
          </Link>

          {/* User Avatar */}
          <Link href="/settings">
            <div className="w-8 h-8 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xs font-bold hover:ring-2 hover:ring-brand-core/30 transition-all cursor-pointer">
              {user?.name ? user.name[0].toUpperCase() : "A"}
            </div>
          </Link>
        </div>
      </header>

      {/* Command Palette Modal */}
      <CommandPalette
        open={commandPaletteOpen}
        onOpenChange={setCommandPaletteOpen}
      />
    </>
  );
}

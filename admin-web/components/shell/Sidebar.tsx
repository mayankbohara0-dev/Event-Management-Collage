"use client";

import React, { Suspense } from "react";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import {
  LayoutDashboard,
  CalendarDays,
  Calendar,
  Users,
  GraduationCap,
  ScanLine,
  MessageSquareText,
  Megaphone,
  BarChart3,
  ShieldCheck,
  Building2,
  Settings,
  LogOut,
  Sparkles,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { isFeatureEnabled } from "@/lib/flags";
import { createClient } from "@/lib/supabase/client";
import { toast } from "sonner";

interface NavItem {
  label: string;
  href: string;
  icon: React.ReactNode;
  badge?: string;
  flag?: keyof typeof import("@/lib/flags").flags;
}

interface NavGroup {
  group: string;
  items: NavItem[];
}

const NAV_GROUPS: NavGroup[] = [
  {
    group: "Overview",
    items: [
      {
        label: "Dashboard",
        href: "/dashboard",
        icon: <LayoutDashboard size={18} />,
      },
    ],
  },
  {
    group: "Events",
    items: [
      {
        label: "All events",
        href: "/events",
        icon: <CalendarDays size={18} />,
      },
      {
        label: "Calendar",
        href: "/events?view=calendar",
        icon: <Calendar size={18} />,
      },
    ],
  },
  {
    group: "People",
    items: [
      {
        label: "Registrations",
        href: "/registrations",
        icon: <Users size={18} />,
      },
      {
        label: "Students",
        href: "/students",
        icon: <GraduationCap size={18} />,
      },
    ],
  },
  {
    group: "On the day",
    items: [
      {
        label: "Check-in",
        href: "/checkin",
        icon: <ScanLine size={18} />,
        badge: "Live",
      },
    ],
  },
  {
    group: "Engage",
    items: [
      {
        label: "Feedback",
        href: "/feedback",
        icon: <MessageSquareText size={18} />,
      },
      {
        label: "Announcements",
        href: "/announcements",
        icon: <Megaphone size={18} />,
        flag: "broadcastAnnouncements",
        badge: "P2",
      },
    ],
  },
  {
    group: "Insights",
    items: [
      {
        label: "Reports",
        href: "/reports",
        icon: <BarChart3 size={18} />,
      },
    ],
  },
  {
    group: "Organization",
    items: [
      {
        label: "Team",
        href: "/team",
        icon: <ShieldCheck size={18} />,
      },
      {
        label: "Departments",
        href: "/departments",
        icon: <Building2 size={18} />,
      },
      {
        label: "Settings",
        href: "/settings",
        icon: <Settings size={18} />,
      },
    ],
  },
];

function NavItemLink({
  item,
  pathname,
}: {
  item: NavItem;
  pathname: string;
}) {
  const searchParams = useSearchParams();
  const currentView = searchParams ? searchParams.get("view") : null;

  const isCalendar = item.href.includes("view=calendar");
  const isAllEvents = item.href === "/events";

  let isActive = false;
  if (isCalendar) {
    isActive = pathname === "/events" && currentView === "calendar";
  } else if (isAllEvents) {
    isActive = pathname === "/events" && currentView !== "calendar";
  } else {
    isActive =
      pathname === item.href ||
      (item.href !== "/dashboard" &&
        !item.href.includes("?") &&
        pathname.startsWith(item.href));
  }

  return (
    <Link
      href={item.href}
      className={cn(
        "relative flex items-center justify-center lg:justify-between px-2.5 lg:px-3 py-2 rounded-pill text-xs font-medium transition-all group",
        isActive
          ? "bg-brand-tint text-brand-blue font-semibold"
          : "text-ink-2 hover:text-ink hover:bg-fill/70"
      )}
      title={item.label}
    >
      {/* Active sliding indicator bar */}
      {isActive && (
        <motion.div
          layoutId="activeNavIndicator"
          className="hidden lg:block absolute left-1 top-2 bottom-2 w-1 rounded-full bg-brand-core"
          transition={{
            type: "spring",
            stiffness: 450,
            damping: 32,
          }}
        />
      )}

      <div className="flex items-center gap-2.5">
        <span
          className={cn(
            "shrink-0 transition-colors",
            isActive ? "text-brand-core" : "text-ink-3 group-hover:text-ink"
          )}
        >
          {item.icon}
        </span>
        <span className="hidden lg:inline">{item.label}</span>
      </div>

      {item.badge && (
        <span
          className={cn(
            "hidden lg:inline text-[9px] font-bold px-1.5 py-0.2 rounded-full",
            item.badge === "Live"
              ? "bg-semantic-success text-white animate-pulse"
              : "bg-fill text-ink-3"
          )}
        >
          {item.badge}
        </span>
      )}
    </Link>
  );
}

function NavItemFallback({
  item,
  pathname,
}: {
  item: NavItem;
  pathname: string;
}) {
  const isCalendar = item.href.includes("view=calendar");
  const isAllEvents = item.href === "/events";
  const isActive = isCalendar
    ? false
    : isAllEvents
    ? pathname === "/events"
    : pathname === item.href ||
      (!item.href.includes("?") && pathname.startsWith(item.href));

  return (
    <Link
      href={item.href}
      className={cn(
        "relative flex items-center justify-center lg:justify-between px-2.5 lg:px-3 py-2 rounded-pill text-xs font-medium transition-all group",
        isActive
          ? "bg-brand-tint text-brand-blue font-semibold"
          : "text-ink-2 hover:text-ink hover:bg-fill/70"
      )}
      title={item.label}
    >
      <div className="flex items-center gap-2.5">
        <span className="shrink-0 text-ink-3">{item.icon}</span>
        <span className="hidden lg:inline">{item.label}</span>
      </div>
    </Link>
  );
}

interface SidebarProps {
  user?: {
    name?: string;
    email?: string;
    role?: string;
    avatarUrl?: string;
  };
}

export function Sidebar({ user }: SidebarProps) {
  const pathname = usePathname();
  const router = useRouter();
  const supabase = createClient();

  const handleSignOut = async () => {
    try {
      await supabase.auth.signOut();
      toast.success("Signed out successfully");
      router.push("/login");
      router.refresh();
    } catch {
      toast.error("Failed to sign out");
    }
  };

  return (
    <aside className="fixed left-0 top-0 bottom-0 z-40 w-16 md:w-[76px] lg:w-[248px] bg-card border-r border-line flex flex-col justify-between select-none transition-all duration-300">
      {/* Top Header & Brand */}
      <div>
        <div className="h-16 px-4 lg:px-6 flex items-center gap-3 border-b border-line/60">
          <Link href="/dashboard" className="flex items-center gap-2.5">
            <BlobLogo size={34} className="shrink-0" />
            <div className="hidden lg:flex flex-col">
              <span className="font-bold text-base tracking-tight text-ink flex items-center gap-1">
                zest <span className="font-normal text-xs text-brand-core font-mono">admin</span>
              </span>
            </div>
          </Link>
        </div>

        {/* Scrollable Nav Groups */}
        <div className="p-2 lg:p-3 overflow-y-auto max-h-[calc(100vh-140px)] space-y-5">
          {NAV_GROUPS.map((group) => {
            // Filter out flagged items if feature is disabled
            const visibleItems = group.items.filter(
              (item) => !item.flag || isFeatureEnabled(item.flag)
            );

            if (visibleItems.length === 0) return null;

            return (
              <div key={group.group} className="space-y-1">
                <span className="hidden lg:block text-[10px] font-bold uppercase tracking-wider text-ink-3 px-3 mb-1">
                  {group.group}
                </span>

                <div className="space-y-0.5">
                  {visibleItems.map((item) => (
                    <Suspense
                      key={item.href}
                      fallback={<NavItemFallback item={item} pathname={pathname} />}
                    >
                      <NavItemLink item={item} pathname={pathname} />
                    </Suspense>
                  ))}
                </div>
              </div>
            );
          })}

          {/* Dev Design Gallery link */}
          <div className="pt-2 border-t border-line/60">
            <Link
              href="/dev/gallery"
              className={cn(
                "flex items-center justify-center lg:justify-start gap-2.5 px-2.5 lg:px-3 py-2 rounded-pill text-xs font-medium text-accent-lavender hover:bg-accent-lavender/10 transition-colors",
                pathname === "/dev/gallery" && "bg-accent-lavender/15 font-semibold"
              )}
              title="Design System Gallery"
            >
              <Sparkles size={16} />
              <span className="hidden lg:inline">Dev Gallery</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Bottom User Profile Card & Sign Out */}
      <div className="p-2 lg:p-3 border-t border-line/60 bg-page/40">
        <div className="flex items-center justify-between gap-2 p-1.5 rounded-card">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-8 h-8 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xs font-bold shrink-0">
              {user?.name ? user.name[0].toUpperCase() : "A"}
            </div>
            <div className="hidden lg:flex flex-col min-w-0">
              <span className="text-xs font-semibold text-ink truncate">
                {user?.name || "Campus Admin"}
              </span>
              <span className="text-[10px] text-ink-3 capitalize truncate">
                {user?.role || "super_admin"}
              </span>
            </div>
          </div>

          <button
            type="button"
            onClick={handleSignOut}
            className="w-7 h-7 rounded-full flex items-center justify-center text-ink-3 hover:text-semantic-danger hover:bg-semantic-danger-tint transition-colors shrink-0"
            title="Sign out"
          >
            <LogOut size={15} />
          </button>
        </div>
      </div>
    </aside>
  );
}

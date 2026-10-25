"use client";

import React from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import {
  CalendarDays,
  Users,
  ScanLine,
  Clock,
  TrendingUp,
  ArrowRight,
  CheckCircle2,
  AlertCircle,
  Circle,
} from "lucide-react";
import { format } from "date-fns";
import { StatCard } from "@/components/ui/StatCard";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";

interface DashboardClientProps {
  stats: {
    totalEvents: number;
    publishedEvents: number;
    totalRegistrations: number;
    pendingRegistrations: number;
    attendanceCount: number;
    totalStudents: number;
  };
  recentEvents: any[];
  upcomingEvents: any[];
  recentRegistrations: any[];
}

const stagger = {
  container: {
    hidden: {},
    show: { transition: { staggerChildren: 0.03 } },
  },
  item: {
    hidden: { opacity: 0, y: 8 },
    show: { opacity: 1, y: 0, transition: { duration: 0.2, ease: "easeOut" } },
  },
};

function VisibilityBadge({ v }: { v: string }) {
  if (v === "published")
    return <Badge variant="success" size="sm">Published</Badge>;
  if (v === "draft")
    return <Badge variant="default" size="sm">Draft</Badge>;
  return <Badge variant="warning" size="sm">Archived</Badge>;
}

function StatusBadge({ status }: { status: string }) {
  if (status === "approved")
    return <Badge variant="success" size="sm">Approved</Badge>;
  if (status === "pending")
    return <Badge variant="warning" size="sm">Pending</Badge>;
  if (status === "rejected")
    return <Badge variant="danger" size="sm">Rejected</Badge>;
  return <Badge variant="default" size="sm">Waitlisted</Badge>;
}

export function DashboardClient({
  stats,
  recentEvents,
  upcomingEvents,
  recentRegistrations,
}: DashboardClientProps) {
  const attendanceRate =
    stats.totalRegistrations > 0
      ? Math.round((stats.attendanceCount / stats.totalRegistrations) * 100)
      : 0;

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
      >
        <h1 className="text-2xl lg:text-3xl font-bold text-ink tracking-tight">
          Good morning,{" "}
          <span className="serif-accent font-normal text-brand-blue">
            organizer
          </span>
          .
        </h1>
        <p className="text-sm text-ink-2 mt-1">
          Here&apos;s what&apos;s happening across campus today.
        </p>
      </motion.div>

      {/* Stats Row */}
      <motion.div
        variants={stagger.container}
        initial="hidden"
        animate="show"
        className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4"
      >
        <motion.div variants={stagger.item} className="col-span-1">
          <StatCard
            label="Total Events"
            value={stats.totalEvents}
            icon={<CalendarDays size={18} />}
            sub={`${stats.publishedEvents} published`}
            color="brand"
          />
        </motion.div>
        <motion.div variants={stagger.item} className="col-span-1">
          <StatCard
            label="Registrations"
            value={stats.totalRegistrations}
            icon={<Users size={18} />}
            sub={`${stats.pendingRegistrations} pending`}
            color="warning"
          />
        </motion.div>
        <motion.div variants={stagger.item} className="col-span-1">
          <StatCard
            label="Check-ins"
            value={stats.attendanceCount}
            icon={<ScanLine size={18} />}
            sub={`${attendanceRate}% rate`}
            color="success"
          />
        </motion.div>
        <motion.div variants={stagger.item} className="col-span-1">
          <StatCard
            label="Students"
            value={stats.totalStudents}
            icon={<TrendingUp size={18} />}
            sub="Registered on platform"
            color="default"
          />
        </motion.div>
        <motion.div variants={stagger.item} className="col-span-1">
          <StatCard
            label="Pending Review"
            value={stats.pendingRegistrations}
            icon={<Clock size={18} />}
            sub="Need approval"
            color="danger"
          />
        </motion.div>
        <motion.div variants={stagger.item} className="col-span-1">
          <StatCard
            label="Upcoming"
            value={upcomingEvents.length}
            icon={<CalendarDays size={18} />}
            sub="In next 30 days"
            color="default"
          />
        </motion.div>
      </motion.div>

      {/* Main Grid */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        {/* Left: Upcoming Events */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.2 }}
          className="xl:col-span-2 bg-card rounded-card border border-line p-6"
        >
          <div className="flex items-center justify-between mb-5">
            <div>
              <h2 className="text-base font-semibold text-ink">
                Upcoming Events
              </h2>
              <p className="text-xs text-ink-3 mt-0.5">Next 30 days</p>
            </div>
            <Link href="/events">
              <Button size="sm" variant="ghost" rightIcon={<ArrowRight size={14} />}>
                View all
              </Button>
            </Link>
          </div>

          {upcomingEvents.length === 0 ? (
            <div className="text-center py-12 text-ink-3 text-sm">
              No upcoming events in the next 30 days.
            </div>
          ) : (
            <div className="space-y-2">
              {upcomingEvents.map((event) => (
                <div
                  key={event.id}
                >
                  <Link
                    href={`/events/${event.id}`}
                    className="flex items-center gap-4 p-3 rounded-card hover:bg-fill/70 transition-colors group"
                  >
                    <div className="w-10 h-10 rounded-card bg-brand-tint flex flex-col items-center justify-center shrink-0">
                      <span className="text-[10px] font-bold text-brand-blue uppercase">
                        {format(new Date(event.start_date), "MMM")}
                      </span>
                      <span className="text-sm font-bold text-brand-blue leading-tight">
                        {format(new Date(event.start_date), "d")}
                      </span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-ink truncate group-hover:text-brand-blue transition-colors">
                        {event.title}
                      </p>
                      <p className="text-xs text-ink-3 truncate mt-0.5">
                        {event.venue || "Venue TBD"} ·{" "}
                        {format(new Date(event.start_date), "h:mm a")}
                      </p>
                    </div>
                    <VisibilityBadge v={event.visibility} />
                  </Link>
                </div>
              ))}
            </div>
          )}
        </motion.div>

        {/* Right: Recent Registrations */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.2 }}
          className="bg-card rounded-card border border-line p-6"
        >
          <div className="flex items-center justify-between mb-5">
            <div>
              <h2 className="text-base font-semibold text-ink">
                Recent Signups
              </h2>
              <p className="text-xs text-ink-3 mt-0.5">Latest registrations</p>
            </div>
            <Link href="/registrations">
              <Button size="sm" variant="ghost" rightIcon={<ArrowRight size={14} />}>
                All
              </Button>
            </Link>
          </div>

          {recentRegistrations.length === 0 ? (
            <div className="text-center py-12 text-ink-3 text-sm">
              No registrations yet.
            </div>
          ) : (
            <div className="space-y-3">
              {recentRegistrations.map((reg) => {
                const student = Array.isArray(reg.student_profiles)
                  ? reg.student_profiles[0]
                  : reg.student_profiles;
                const event = Array.isArray(reg.events)
                  ? reg.events[0]
                  : reg.events;
                return (
                  <div
                    key={reg.id}
                    className="flex items-start gap-3"
                  >
                    <div className="w-7 h-7 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xs font-bold shrink-0 mt-0.5">
                      {student?.name ? student.name[0].toUpperCase() : "?"}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-semibold text-ink truncate">
                        {student?.name || "Unknown"}
                      </p>
                      <p className="text-[11px] text-ink-3 truncate">
                        {event?.title || "Event"}
                      </p>
                      <p className="text-[10px] text-ink-3 mt-0.5">
                        {format(new Date(reg.created_at), "d MMM · h:mm a")}
                      </p>
                    </div>
                    <StatusBadge status={reg.status} />
                  </div>
                );
              })}
            </div>
          )}
        </motion.div>
      </div>

      {/* Quick Actions Emphasis Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4, duration: 0.4 }}
        className="relative overflow-hidden rounded-hero border border-brand-blue/20 bg-gradient-to-br from-brand-tint via-white to-brand-sky/10 p-6"
      >
        <div className="absolute -right-8 -top-8 w-40 h-40 rounded-full bg-brand-sky/20 blur-3xl pointer-events-none" />
        <div className="absolute -left-4 -bottom-8 w-32 h-32 rounded-full bg-brand-blue/15 blur-3xl pointer-events-none" />
        <div className="relative z-10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <h3 className="text-base font-bold text-ink">
              Ready to go{" "}
              <span className="serif-accent font-normal text-brand-blue">
                live
              </span>
              ?
            </h3>
            <p className="text-sm text-ink-2 mt-1">
              Open the check-in scanner to start scanning QR passes at the gate.
            </p>
          </div>
          <div className="flex gap-3 shrink-0">
            <Link href="/checkin">
              <Button
                size="md"
                leftIcon={<ScanLine size={16} />}
              >
                Open Scanner
              </Button>
            </Link>
            <Link href="/events/new">
              <Button size="md" variant="outline">
                Create Event
              </Button>
            </Link>
          </div>
        </div>
      </motion.div>
    </div>
  );
}

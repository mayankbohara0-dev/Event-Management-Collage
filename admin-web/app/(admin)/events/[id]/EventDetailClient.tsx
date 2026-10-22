"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import {
  ArrowLeft,
  Calendar,
  MapPin,
  Users,
  Edit,
  ScanLine,
  Star,
  CheckCircle2,
  Clock,
  Eye,
  EyeOff,
  Globe,
  Mail,
  Phone,
  Tag,
  ChevronRight,
  Trash2,
  ListPlus,
  FileSpreadsheet,
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { StatCard } from "@/components/ui/StatCard";
import { createClient } from "@/lib/supabase/client";

interface EventDetailClientProps {
  event: any;
  stats: {
    totalReg: number;
    approvedReg: number;
    pendingReg: number;
    checkedIn: number;
    avgRating: number | null;
    feedbackCount: number;
  };
  recentRegistrations: any[];
}

function VisibilityBadge({ v }: { v: string }) {
  if (v === "published")
    return <Badge variant="success">Published</Badge>;
  if (v === "draft")
    return <Badge variant="default">Draft</Badge>;
  return <Badge variant="warning">Archived</Badge>;
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

export function EventDetailClient({
  event,
  stats,
  recentRegistrations,
}: EventDetailClientProps) {
  const router = useRouter();
  const supabase = createClient();
  const [changingVis, setChangingVis] = useState(false);

  const dept = Array.isArray(event.departments)
    ? event.departments[0]
    : event.departments;
  const cat = Array.isArray(event.event_categories)
    ? event.event_categories[0]
    : event.event_categories;

  const handleVisibilityToggle = async () => {
    const next =
      event.visibility === "published"
        ? "draft"
        : event.visibility === "draft"
        ? "published"
        : "archived";

    setChangingVis(true);
    const { error } = await (supabase
      .from("events") as any)
      .update({ visibility: next })
      .eq("id", event.id);
    setChangingVis(false);

    if (error) {
      toast.error("Failed to update visibility.");
    } else {
      toast.success(`Event is now ${next}.`);
      router.refresh();
    }
  };

  const handleDelete = async () => {
    if (
      !confirm(
        `Are you sure you want to delete "${event.title}"? This cannot be undone.`
      )
    )
      return;
    const { error } = await supabase
      .from("events")
      .delete()
      .eq("id", event.id);
    if (error) {
      toast.error("Failed to delete event.");
    } else {
      toast.success("Event deleted.");
      router.push("/events");
    }
  };

  const attendanceRate =
    stats.totalReg > 0
      ? Math.round((stats.checkedIn / stats.totalReg) * 100)
      : 0;

  return (
    <div className="space-y-6">
      {/* Back + Header */}
      <div className="flex flex-col sm:flex-row sm:items-start gap-4 justify-between">
        <div className="flex items-start gap-3">
          <Link href="/events">
            <button className="mt-1 p-1.5 rounded-card hover:bg-fill transition-colors text-ink-3">
              <ArrowLeft size={18} />
            </button>
          </Link>
          <div>
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-xl font-bold text-ink tracking-tight">
                {event.title}
              </h1>
              <VisibilityBadge v={event.visibility} />
            </div>
            <p className="text-sm text-ink-2 mt-1">{event.short_description}</p>
          </div>
        </div>
        <div className="flex gap-2 shrink-0 flex-wrap">
          <Button
            size="sm"
            variant="outline"
            onClick={handleVisibilityToggle}
            isLoading={changingVis}
            leftIcon={event.visibility === "published" ? <EyeOff size={14} /> : <Eye size={14} />}
          >
            {event.visibility === "published" ? "Unpublish" : "Publish"}
          </Button>
          <Link href={`/events/${event.id}/builder`}>
            <Button size="sm" variant="outline" leftIcon={<ListPlus size={14} />}>
              Form Builder
            </Button>
          </Link>
          <Link href={`/events/${event.id}/responses`}>
            <Button size="sm" variant="outline" leftIcon={<FileSpreadsheet size={14} />}>
              Responses
            </Button>
          </Link>
          <Link href={`/events/${event.id}/edit`}>
            <Button size="sm" variant="outline" leftIcon={<Edit size={14} />}>
              Edit
            </Button>
          </Link>
          <Link href={`/checkin?event=${event.id}`}>
            <Button size="sm" leftIcon={<ScanLine size={14} />}>
              Scan
            </Button>
          </Link>
          <button
            onClick={handleDelete}
            className="p-2 rounded-card text-semantic-danger hover:bg-semantic-danger/10 transition-colors"
            title="Delete event"
          >
            <Trash2 size={16} />
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard
          label="Registrations"
          value={stats.totalReg}
          icon={<Users size={16} />}
          sub={`${stats.approvedReg} approved`}
          color="brand"
        />
        <StatCard
          label="Pending"
          value={stats.pendingReg}
          icon={<Clock size={16} />}
          sub="Awaiting review"
          color="warning"
        />
        <StatCard
          label="Checked In"
          value={stats.checkedIn}
          icon={<CheckCircle2 size={16} />}
          sub={`${attendanceRate}% attendance`}
          color="success"
        />
        <StatCard
          label="Avg Rating"
          value={stats.avgRating ? stats.avgRating.toFixed(1) : "—"}
          icon={<Star size={16} />}
          sub={`${stats.feedbackCount} responses`}
          color="default"
        />
      </div>

      {/* Event Details + Registrations */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        {/* Details */}
        <div className="xl:col-span-1 space-y-4">
          {/* Banner */}
          {event.banner_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={event.banner_url}
              alt={event.title}
              className="w-full h-48 object-cover rounded-card border border-line"
            />
          ) : (
            <div className="w-full h-48 rounded-card border border-line bg-gradient-to-br from-brand-tint to-brand-sky/20 flex items-center justify-center">
              <Calendar size={40} className="text-brand-sky/40" />
            </div>
          )}

          <div className="bg-card rounded-card border border-line p-5 space-y-4">
            <h2 className="text-sm font-semibold text-ink-2 uppercase tracking-wider">
              Details
            </h2>

            <div className="space-y-3">
              <InfoRow icon={<Calendar size={14} />} label="Starts">
                {format(new Date(event.start_date), "d MMM yyyy · h:mm a")}
              </InfoRow>
              <InfoRow icon={<Calendar size={14} />} label="Ends">
                {format(new Date(event.end_date), "d MMM yyyy · h:mm a")}
              </InfoRow>
              {event.venue && (
                <InfoRow icon={<MapPin size={14} />} label="Venue">
                  {event.venue}
                  {event.room && ` · Room ${event.room}`}
                </InfoRow>
              )}
              {event.max_seats && (
                <InfoRow icon={<Users size={14} />} label="Seats">
                  {event.max_seats} max
                </InfoRow>
              )}
              {cat && (
                <InfoRow icon={<Tag size={14} />} label="Category">
                  {cat.name}
                </InfoRow>
              )}
              {dept && (
                <InfoRow icon={<Globe size={14} />} label="Department">
                  {dept.name} ({dept.code})
                </InfoRow>
              )}
              {event.coordinator && (
                <InfoRow icon={<Users size={14} />} label="Coordinator">
                  {event.coordinator}
                </InfoRow>
              )}
              {event.contact_number && (
                <InfoRow icon={<Phone size={14} />} label="Contact">
                  {event.contact_number}
                </InfoRow>
              )}
              {event.email && (
                <InfoRow icon={<Mail size={14} />} label="Email">
                  {event.email}
                </InfoRow>
              )}
            </div>

            {(event.tags || []).length > 0 && (
              <div className="pt-3 border-t border-line">
                <p className="text-xs font-semibold text-ink-2 uppercase tracking-wider mb-2">
                  Tags
                </p>
                <div className="flex flex-wrap gap-1.5">
                  {event.tags.map((tag: string) => (
                    <span
                      key={tag}
                      className="text-xs bg-fill text-ink-2 px-2 py-0.5 rounded-full"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Quick Links */}
          <div className="bg-card rounded-card border border-line divide-y divide-line">
            <Link
              href={`/registrations?event=${event.id}`}
              className="flex items-center justify-between px-5 py-3 text-sm text-ink hover:bg-fill/40 transition-colors"
            >
              <span>View all registrations</span>
              <ChevronRight size={14} className="text-ink-3" />
            </Link>
            <Link
              href={`/feedback?event=${event.id}`}
              className="flex items-center justify-between px-5 py-3 text-sm text-ink hover:bg-fill/40 transition-colors"
            >
              <span>View feedback</span>
              <ChevronRight size={14} className="text-ink-3" />
            </Link>
            <Link
              href={`/reports?event=${event.id}`}
              className="flex items-center justify-between px-5 py-3 text-sm text-ink hover:bg-fill/40 transition-colors"
            >
              <span>Export report</span>
              <ChevronRight size={14} className="text-ink-3" />
            </Link>
          </div>
        </div>

        {/* Recent Registrations */}
        <div className="xl:col-span-2 bg-card rounded-card border border-line p-6">
          <div className="flex items-center justify-between mb-5">
            <h2 className="text-base font-semibold text-ink">
              Recent Registrations
            </h2>
            <Link href={`/registrations?event=${event.id}`}>
              <Button size="sm" variant="ghost" rightIcon={<ChevronRight size={14} />}>
                View all
              </Button>
            </Link>
          </div>

          {recentRegistrations.length === 0 ? (
            <div className="text-center py-12 text-ink-3 text-sm">
              No registrations yet.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-line">
                    <th className="pb-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                      Student
                    </th>
                    <th className="pb-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                      Roll No.
                    </th>
                    <th className="pb-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                      Registered
                    </th>
                    <th className="pb-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                      Status
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-line">
                  {recentRegistrations.map((reg) => {
                    const student = Array.isArray(reg.student_profiles)
                      ? reg.student_profiles[0]
                      : reg.student_profiles;
                    return (
                      <tr key={reg.id} className="hover:bg-fill/30 transition-colors">
                        <td className="py-3 text-sm font-medium text-ink">
                          {student?.name || "Unknown"}
                        </td>
                        <td className="py-3 text-xs text-ink-2">
                          {student?.roll_number || "—"}
                        </td>
                        <td className="py-3 text-xs text-ink-3">
                          {format(new Date(reg.created_at), "d MMM · h:mm a")}
                        </td>
                        <td className="py-3">
                          <StatusBadge status={reg.status} />
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Long Description / Rules */}
      {(event.long_description || event.rules || event.eligibility) && (
        <div className="bg-card rounded-card border border-line p-6 space-y-4">
          <h2 className="text-base font-semibold text-ink">About this event</h2>
          {event.long_description && (
            <div>
              <p className="text-xs font-semibold text-ink-2 uppercase tracking-wider mb-2">
                Description
              </p>
              <p className="text-sm text-ink-2 leading-relaxed whitespace-pre-wrap">
                {event.long_description}
              </p>
            </div>
          )}
          {event.eligibility && (
            <div className="pt-4 border-t border-line">
              <p className="text-xs font-semibold text-ink-2 uppercase tracking-wider mb-2">
                Eligibility
              </p>
              <p className="text-sm text-ink-2 whitespace-pre-wrap">
                {event.eligibility}
              </p>
            </div>
          )}
          {event.rules && (
            <div className="pt-4 border-t border-line">
              <p className="text-xs font-semibold text-ink-2 uppercase tracking-wider mb-2">
                Rules
              </p>
              <p className="text-sm text-ink-2 whitespace-pre-wrap">
                {event.rules}
              </p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function InfoRow({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex items-start gap-3">
      <span className="text-ink-3 mt-0.5 shrink-0">{icon}</span>
      <div>
        <p className="text-[10px] font-bold uppercase tracking-wider text-ink-3">
          {label}
        </p>
        <p className="text-sm text-ink mt-0.5">{children}</p>
      </div>
    </div>
  );
}

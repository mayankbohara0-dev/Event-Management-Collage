"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import {
  Plus,
  Search,
  Calendar,
  MapPin,
  Users,
  Filter,
  LayoutGrid,
  LayoutList,
  CalendarDays,
  Eye,
  Edit,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, isSameDay, addMonths, subMonths } from "date-fns";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Badge } from "@/components/ui/Badge";
import { Select } from "@/components/ui/Select";
import { EmptyState } from "@/components/ui/EmptyState";

interface Event {
  id: string;
  title: string;
  short_description: string;
  start_date: string;
  end_date: string;
  visibility: "draft" | "published" | "archived";
  venue: string | null;
  tags: string[] | null;
  banner_url: string | null;
  max_seats: number | null;
  created_at: string;
  department_id: string | null;
  category_id: string | null;
  departments?: { name: string; code: string } | null;
  event_categories?: { name: string } | null;
}

interface EventsClientProps {
  initialEvents: Event[];
  categories: { id: string; name: string }[];
  departments: { id: string; name: string; code: string }[];
  initialView?: "grid" | "list" | "calendar";
}

function VisibilityBadge({ v }: { v: string }) {
  if (v === "published")
    return <Badge variant="success" size="sm">Published</Badge>;
  if (v === "draft")
    return <Badge variant="default" size="sm">Draft</Badge>;
  return <Badge variant="warning" size="sm">Archived</Badge>;
}

function EventCard({ event }: { event: Event }) {
  const dept = Array.isArray(event.departments)
    ? event.departments[0]
    : event.departments;
  const cat = Array.isArray(event.event_categories)
    ? event.event_categories[0]
    : event.event_categories;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, scale: 0.97 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.97 }}
      className="bg-card rounded-card border border-line overflow-hidden group hover:shadow-card hover:border-brand-sky/30 transition-all duration-200"
    >
      {/* Banner */}
      <div className="h-32 bg-gradient-to-br from-brand-tint to-brand-sky/20 relative overflow-hidden">
        {event.banner_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={event.banner_url}
            alt={event.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <Calendar size={32} className="text-brand-sky/40" />
          </div>
        )}
        <div className="absolute top-2 right-2">
          <VisibilityBadge v={event.visibility} />
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        <h3 className="font-semibold text-sm text-ink truncate group-hover:text-brand-blue transition-colors">
          {event.title}
        </h3>
        <p className="text-xs text-ink-3 mt-1 line-clamp-2">
          {event.short_description}
        </p>

        <div className="mt-3 space-y-1.5">
          <div className="flex items-center gap-1.5 text-xs text-ink-2">
            <Calendar size={12} className="text-ink-3 shrink-0" />
            <span>{format(new Date(event.start_date), "d MMM yyyy · h:mm a")}</span>
          </div>
          {event.venue && (
            <div className="flex items-center gap-1.5 text-xs text-ink-2">
              <MapPin size={12} className="text-ink-3 shrink-0" />
              <span className="truncate">{event.venue}</span>
            </div>
          )}
          {event.max_seats && (
            <div className="flex items-center gap-1.5 text-xs text-ink-2">
              <Users size={12} className="text-ink-3 shrink-0" />
              <span>{event.max_seats} seats</span>
            </div>
          )}
        </div>

        <div className="mt-3 flex flex-wrap gap-1">
          {cat && (
            <span className="text-[10px] font-medium bg-brand-tint text-brand-blue px-2 py-0.5 rounded-full">
              {cat.name}
            </span>
          )}
          {dept && (
            <span className="text-[10px] font-medium bg-fill text-ink-2 px-2 py-0.5 rounded-full">
              {dept.code}
            </span>
          )}
          {(event.tags || []).slice(0, 2).map((tag) => (
            <span
              key={tag}
              className="text-[10px] font-medium bg-fill text-ink-3 px-2 py-0.5 rounded-full"
            >
              {tag}
            </span>
          ))}
        </div>

        {/* Actions */}
        <div className="mt-4 flex gap-2">
          <Link href={`/events/${event.id}`} className="flex-1">
            <Button size="sm" variant="outline" fullWidth leftIcon={<Eye size={13} />}>
              View
            </Button>
          </Link>
          <Link href={`/events/${event.id}/edit`} className="flex-1">
            <Button size="sm" variant="ghost" fullWidth leftIcon={<Edit size={13} />}>
              Edit
            </Button>
          </Link>
        </div>
      </div>
    </motion.div>
  );
}

function EventRow({ event }: { event: Event }) {
  const dept = Array.isArray(event.departments)
    ? event.departments[0]
    : event.departments;
  const cat = Array.isArray(event.event_categories)
    ? event.event_categories[0]
    : event.event_categories;

  return (
    <motion.tr
      layout
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="group hover:bg-fill/40 transition-colors"
    >
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-card bg-brand-tint flex items-center justify-center shrink-0">
            <Calendar size={14} className="text-brand-blue" />
          </div>
          <div className="min-w-0">
            <Link
              href={`/events/${event.id}`}
              className="text-sm font-semibold text-ink hover:text-brand-blue transition-colors truncate block"
            >
              {event.title}
            </Link>
            {cat && (
              <span className="text-xs text-ink-3">{cat.name}</span>
            )}
          </div>
        </div>
      </td>
      <td className="px-4 py-3 text-xs text-ink-2 whitespace-nowrap">
        {format(new Date(event.start_date), "d MMM yyyy")}
        <br />
        <span className="text-ink-3">{format(new Date(event.start_date), "h:mm a")}</span>
      </td>
      <td className="px-4 py-3 text-xs text-ink-2 truncate max-w-[140px]">
        {event.venue || <span className="text-ink-3">—</span>}
      </td>
      <td className="px-4 py-3 text-xs text-ink-2">
        {dept?.code || <span className="text-ink-3">—</span>}
      </td>
      <td className="px-4 py-3">
        <VisibilityBadge v={event.visibility} />
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <Link href={`/events/${event.id}`}>
            <Button size="sm" variant="ghost" leftIcon={<Eye size={13} />}>
              View
            </Button>
          </Link>
          <Link href={`/events/${event.id}/edit`}>
            <Button size="sm" variant="ghost" leftIcon={<Edit size={13} />}>
              Edit
            </Button>
          </Link>
        </div>
      </td>
    </motion.tr>
  );
}

export function EventsClient({
  initialEvents,
  categories,
  departments,
  initialView = "grid",
}: EventsClientProps) {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [filterVis, setFilterVis] = useState("all");
  const [filterCat, setFilterCat] = useState("all");
  const [filterDept, setFilterDept] = useState("all");
  const [view, setView] = useState<"grid" | "list" | "calendar">(initialView);
  const [calMonth, setCalMonth] = useState(() => new Date());

  const filtered = useMemo(() => {
    return initialEvents.filter((e) => {
      const q = search.toLowerCase();
      const matchSearch =
        !q ||
        e.title.toLowerCase().includes(q) ||
        e.short_description.toLowerCase().includes(q) ||
        (e.venue || "").toLowerCase().includes(q);
      const matchVis = filterVis === "all" || e.visibility === filterVis;
      const matchCat = filterCat === "all" || e.category_id === filterCat;
      const matchDept = filterDept === "all" || e.department_id === filterDept;
      return matchSearch && matchVis && matchCat && matchDept;
    });
  }, [initialEvents, search, filterVis, filterCat, filterDept]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            <span className="serif-accent font-normal text-brand-blue">All</span>{" "}
            Events
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            {initialEvents.length} total · {filtered.length} shown
          </p>
        </div>
        <Link href="/events/new">
          <Button leftIcon={<Plus size={16} />}>New Event</Button>
        </Link>
      </div>

      {/* Filters Bar */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex-1">
          <Input
            placeholder="Search events…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            leftIcon={<Search size={15} />}
          />
        </div>
        <Select
          value={filterVis}
          onChange={(e) => setFilterVis(e.target.value)}
          className="sm:w-36"
        >
          <option value="all">All status</option>
          <option value="published">Published</option>
          <option value="draft">Draft</option>
          <option value="archived">Archived</option>
        </Select>
        <Select
          value={filterCat}
          onChange={(e) => setFilterCat(e.target.value)}
          className="sm:w-40"
        >
          <option value="all">All categories</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </Select>
        <Select
          value={filterDept}
          onChange={(e) => setFilterDept(e.target.value)}
          className="sm:w-44"
        >
          <option value="all">All departments</option>
          {departments.map((d) => (
            <option key={d.id} value={d.id}>
              {d.code} — {d.name}
            </option>
          ))}
        </Select>
        {/* View toggle */}
        <div className="flex items-center gap-1 bg-fill rounded-card p-1">
          <button
            onClick={() => setView("grid")}
            className={`p-1.5 rounded-card transition-colors ${
              view === "grid"
                ? "bg-card shadow-sm text-brand-blue"
                : "text-ink-3 hover:text-ink"
            }`}
            title="Grid view"
          >
            <LayoutGrid size={16} />
          </button>
          <button
            onClick={() => setView("list")}
            className={`p-1.5 rounded-card transition-colors ${
              view === "list"
                ? "bg-card shadow-sm text-brand-blue"
                : "text-ink-3 hover:text-ink"
            }`}
            title="List view"
          >
            <LayoutList size={16} />
          </button>
          <button
            onClick={() => setView("calendar")}
            className={`p-1.5 rounded-card transition-colors ${
              view === "calendar"
                ? "bg-card shadow-sm text-brand-blue"
                : "text-ink-3 hover:text-ink"
            }`}
            title="Calendar view"
          >
            <CalendarDays size={16} />
          </button>
        </div>
      </div>

      {/* Content */}
      {filtered.length === 0 ? (
        <EmptyState
          icon={<Calendar size={40} />}
          title="No events found"
          description={
            search
              ? `No events match "${search}".`
              : "Create your first campus event to get started."
          }
          action={
            <Link href="/events/new">
              <Button leftIcon={<Plus size={15} />}>Create Event</Button>
            </Link>
          }
        />
      ) : view === "grid" ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filtered.map((event) => (
            <EventCard key={event.id} event={event} />
          ))}
        </div>
      ) : view === "list" ? (
        <div className="bg-card rounded-card border border-line overflow-hidden">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-line bg-fill/50">
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">Event</th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">Date</th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">Venue</th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">Dept</th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">Status</th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {filtered.map((event) => (
                <EventRow key={event.id} event={event} />
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        /* Calendar View */
        <div className="bg-card rounded-card border border-line overflow-hidden">
          {/* Calendar Header */}
          <div className="flex items-center justify-between px-6 py-4 border-b border-line">
            <button
              onClick={() => setCalMonth((m) => subMonths(m, 1))}
              className="p-2 rounded-card hover:bg-fill transition-colors text-ink-2"
            >
              <ChevronLeft size={18} />
            </button>
            <h2 className="text-base font-semibold text-ink">
              {format(calMonth, "MMMM yyyy")}
            </h2>
            <button
              onClick={() => setCalMonth((m) => addMonths(m, 1))}
              className="p-2 rounded-card hover:bg-fill transition-colors text-ink-2"
            >
              <ChevronRight size={18} />
            </button>
          </div>

          {/* Day headers */}
          <div className="grid grid-cols-7 border-b border-line">
            {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((d) => (
              <div key={d} className="px-2 py-2 text-center text-[11px] font-semibold text-ink-3 uppercase tracking-wider">
                {d}
              </div>
            ))}
          </div>

          {/* Calendar Grid */}
          <div className="grid grid-cols-7">
            {(() => {
              const start = startOfMonth(calMonth);
              const end = endOfMonth(calMonth);
              const days = eachDayOfInterval({ start, end });
              // Pad start with blanks
              const startPad = start.getDay();
              const allCells: React.ReactNode[] = [];
              for (let i = 0; i < startPad; i++) {
                allCells.push(<div key={`pad-${i}`} className="min-h-[80px] border-b border-r border-line/50 bg-fill/20" />);
              }
              days.forEach((day) => {
                const dayEvents = initialEvents.filter((e) =>
                  isSameDay(new Date(e.start_date), day)
                );
                const isToday = isSameDay(day, new Date());
                allCells.push(
                  <div
                    key={day.toISOString()}
                    className={`min-h-[80px] border-b border-r border-line/50 p-1.5 ${
                      !isSameMonth(day, calMonth) ? "bg-fill/20" : ""
                    }`}
                  >
                    <span
                      className={`inline-flex items-center justify-center w-6 h-6 rounded-full text-xs font-semibold mb-1 ${
                        isToday
                          ? "bg-brand-core text-white"
                          : "text-ink-2"
                      }`}
                    >
                      {format(day, "d")}
                    </span>
                    <div className="space-y-0.5">
                      {dayEvents.slice(0, 3).map((ev) => (
                        <Link
                          key={ev.id}
                          href={`/events/${ev.id}`}
                          className={`block text-[10px] font-medium px-1.5 py-0.5 rounded truncate transition-colors ${
                            ev.visibility === "published"
                              ? "bg-semantic-success-tint text-semantic-success hover:bg-semantic-success hover:text-white"
                              : ev.visibility === "draft"
                              ? "bg-brand-tint text-brand-blue hover:bg-brand-core hover:text-white"
                              : "bg-fill text-ink-3"
                          }`}
                          title={ev.title}
                        >
                          {ev.title}
                        </Link>
                      ))}
                      {dayEvents.length > 3 && (
                        <span className="text-[10px] text-ink-3 px-1">
                          +{dayEvents.length - 3} more
                        </span>
                      )}
                    </div>
                  </div>
                );
              });
              return allCells;
            })()}
          </div>
        </div>
      )}
    </div>
  );
}

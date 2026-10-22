"use client";

import React, { useState, useMemo } from "react";
import { motion } from "framer-motion";
import { Star, Search, MessageSquare } from "lucide-react";
import { format } from "date-fns";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";

interface FeedbackClientProps {
  feedback: any[];
  events: any[];
  preFilterEvent: string | null;
}

function RatingStars({ rating }: { rating: number }) {
  return (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map((i) => (
        <Star
          key={i}
          size={14}
          className={
            i <= rating
              ? "text-accent-lemon fill-accent-lemon"
              : "text-line fill-line"
          }
        />
      ))}
    </div>
  );
}

export function FeedbackClient({
  feedback,
  events,
  preFilterEvent,
}: FeedbackClientProps) {
  const [search, setSearch] = useState("");
  const [filterEvent, setFilterEvent] = useState(preFilterEvent || "all");
  const [filterRating, setFilterRating] = useState("all");

  const filtered = useMemo(() => {
    return feedback.filter((f) => {
      const event = Array.isArray(f.events) ? f.events[0] : f.events;
      const student = Array.isArray(f.student_profiles)
        ? f.student_profiles[0]
        : f.student_profiles;
      const q = search.toLowerCase();
      const matchSearch =
        !q ||
        (f.review || "").toLowerCase().includes(q) ||
        (student?.name || "").toLowerCase().includes(q) ||
        (event?.title || "").toLowerCase().includes(q);
      const matchEvent = filterEvent === "all" || f.event_id === filterEvent;
      const matchRating =
        filterRating === "all" || String(Math.round(f.rating)) === filterRating;
      return matchSearch && matchEvent && matchRating;
    });
  }, [feedback, search, filterEvent, filterRating]);

  const avgRating =
    filtered.length > 0
      ? filtered.reduce((s, f) => s + f.rating, 0) / filtered.length
      : null;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            <span className="serif-accent font-normal text-brand-blue">
              Feedback
            </span>
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            {filtered.length} responses
            {avgRating !== null && (
              <> · Avg rating: <strong>{avgRating.toFixed(1)}</strong> ★</>
            )}
          </p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex-1">
          <Input
            placeholder="Search reviews or student names…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            leftIcon={<Search size={15} />}
          />
        </div>
        <Select
          value={filterEvent}
          onChange={(e) => setFilterEvent(e.target.value)}
          className="sm:w-52"
        >
          <option value="all">All events</option>
          {events.map((ev) => (
            <option key={ev.id} value={ev.id}>
              {ev.title}
            </option>
          ))}
        </Select>
        <Select
          value={filterRating}
          onChange={(e) => setFilterRating(e.target.value)}
          className="sm:w-36"
        >
          <option value="all">All ratings</option>
          {[5, 4, 3, 2, 1].map((r) => (
            <option key={r} value={String(r)}>
              {r} stars
            </option>
          ))}
        </Select>
      </div>

      {/* Feedback Cards */}
      {filtered.length === 0 ? (
        <div className="text-center py-24 text-ink-3">
          <MessageSquare size={40} className="mx-auto mb-3 opacity-20" />
          <p className="text-sm">No feedback found.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {filtered.map((f, i) => {
            const event = Array.isArray(f.events) ? f.events[0] : f.events;
            const student = Array.isArray(f.student_profiles)
              ? f.student_profiles[0]
              : f.student_profiles;
            return (
              <motion.div
                key={f.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04 }}
                className="bg-card rounded-card border border-line p-5 space-y-3"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-2.5">
                    <div className="w-7 h-7 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xs font-bold shrink-0">
                      {student?.name ? student.name[0].toUpperCase() : "?"}
                    </div>
                    <div>
                      <p className="text-xs font-semibold text-ink">
                        {student?.name || "Anonymous"}
                      </p>
                      {student?.roll_number && (
                        <p className="text-[10px] text-ink-3">
                          {student.roll_number}
                        </p>
                      )}
                    </div>
                  </div>
                  <RatingStars rating={Math.round(f.rating)} />
                </div>

                {f.review && (
                  <p className="text-sm text-ink-2 leading-relaxed">
                    &ldquo;{f.review}&rdquo;
                  </p>
                )}

                <div className="pt-2 border-t border-line">
                  <p className="text-[10px] font-semibold text-ink-3 uppercase tracking-wider">
                    {event?.title || "Event"}
                  </p>
                  <p className="text-[10px] text-ink-3 mt-0.5">
                    {format(new Date(f.created_at), "d MMM yyyy · h:mm a")}
                  </p>
                </div>
              </motion.div>
            );
          })}
        </div>
      )}
    </div>
  );
}

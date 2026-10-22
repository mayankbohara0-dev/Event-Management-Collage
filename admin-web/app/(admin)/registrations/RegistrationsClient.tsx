"use client";

import React, { useState, useMemo, useTransition } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import {
  Search,
  CheckCircle2,
  XCircle,
  Clock,
  Users,
  Download,
  Filter,
  RefreshCw,
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Badge } from "@/components/ui/Badge";
import { Select } from "@/components/ui/Select";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

interface RegistrationsClientProps {
  initialRegistrations: any[];
  events: any[];
  preFilterEvent: string | null;
  preFilterStatus: string | null;
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

export function RegistrationsClient({
  initialRegistrations,
  events,
  preFilterEvent,
  preFilterStatus,
}: RegistrationsClientProps) {
  const supabase = createClient();
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [filterEvent, setFilterEvent] = useState(preFilterEvent || "all");
  const [filterStatus, setFilterStatus] = useState(
    preFilterStatus || "all"
  );
  const [updating, setUpdating] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    return initialRegistrations.filter((reg) => {
      const student = Array.isArray(reg.student_profiles)
        ? reg.student_profiles[0]
        : reg.student_profiles;
      const event = Array.isArray(reg.events) ? reg.events[0] : reg.events;

      const q = search.toLowerCase();
      const matchSearch =
        !q ||
        (student?.name || "").toLowerCase().includes(q) ||
        (student?.roll_number || "").toLowerCase().includes(q) ||
        (student?.enrollment_number || "").toLowerCase().includes(q) ||
        (event?.title || "").toLowerCase().includes(q) ||
        (reg.registration_number || "").toLowerCase().includes(q);
      const matchEvent =
        filterEvent === "all" || reg.event_id === filterEvent;
      const matchStatus =
        filterStatus === "all" || reg.status === filterStatus;
      return matchSearch && matchEvent && matchStatus;
    });
  }, [initialRegistrations, search, filterEvent, filterStatus]);

  const updateStatus = async (regId: string, newStatus: string) => {
    setUpdating(regId);
    const { error } = await (supabase
      .from("registrations") as any)
      .update({ status: newStatus })
      .eq("id", regId);
    setUpdating(null);

    if (error) {
      toast.error("Failed to update status.");
    } else {
      toast.success(`Registration ${newStatus}.`);
      startTransition(() => router.refresh());
    }
  };

  const exportCSV = () => {
    const rows = filtered.map((reg) => {
      const student = Array.isArray(reg.student_profiles)
        ? reg.student_profiles[0]
        : reg.student_profiles;
      const event = Array.isArray(reg.events) ? reg.events[0] : reg.events;
      const dept = Array.isArray(student?.departments)
        ? student.departments[0]
        : student?.departments;
      return [
        reg.registration_number || reg.id,
        student?.name || "",
        student?.roll_number || "",
        student?.enrollment_number || "",
        dept?.code || "",
        event?.title || "",
        reg.status,
        format(new Date(reg.created_at), "d MMM yyyy h:mm a"),
      ];
    });

    const header = [
      "Reg #",
      "Name",
      "Roll No",
      "Enrollment",
      "Dept",
      "Event",
      "Status",
      "Date",
    ];
    const csv = [header, ...rows]
      .map((r) => r.map((v) => `"${v}"`).join(","))
      .join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `registrations-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  // Count by status
  const counts = useMemo(() => {
    const all = initialRegistrations;
    return {
      all: all.length,
      pending: all.filter((r) => r.status === "pending").length,
      approved: all.filter((r) => r.status === "approved").length,
      rejected: all.filter((r) => r.status === "rejected").length,
    };
  }, [initialRegistrations]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            <span className="serif-accent font-normal text-brand-blue">
              Registrations
            </span>
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            {filtered.length} of {initialRegistrations.length} total
          </p>
        </div>
        <Button
          variant="outline"
          leftIcon={<Download size={15} />}
          onClick={exportCSV}
        >
          Export CSV
        </Button>
      </div>

      {/* Status Pills */}
      <div className="flex gap-2 flex-wrap">
        {(
          [
            { key: "all", label: "All", count: counts.all },
            { key: "pending", label: "Pending", count: counts.pending },
            { key: "approved", label: "Approved", count: counts.approved },
            { key: "rejected", label: "Rejected", count: counts.rejected },
          ] as const
        ).map((item) => (
          <button
            key={item.key}
            onClick={() => setFilterStatus(item.key)}
            className={`flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-pill font-medium transition-colors ${
              filterStatus === item.key
                ? "bg-brand-tint text-brand-blue"
                : "bg-fill text-ink-2 hover:text-ink"
            }`}
          >
            {item.label}
            <span
              className={`text-[10px] px-1.5 py-0.5 rounded-full ${
                filterStatus === item.key ? "bg-brand-blue text-white" : "bg-line text-ink-3"
              }`}
            >
              {item.count}
            </span>
          </button>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex-1">
          <Input
            placeholder="Search by name, roll, event…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            leftIcon={<Search size={15} />}
          />
        </div>
        <Select
          value={filterEvent}
          onChange={(e) => setFilterEvent(e.target.value)}
          className="sm:w-56"
        >
          <option value="all">All events</option>
          {events.map((ev) => (
            <option key={ev.id} value={ev.id}>
              {ev.title}
            </option>
          ))}
        </Select>
      </div>

      {/* Table */}
      <div className="bg-card rounded-card border border-line overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-line bg-fill/50">
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                  Student
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                  Roll / Enroll
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider hidden md:table-cell">
                  Event
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider hidden lg:table-cell">
                  Registered
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {filtered.length === 0 ? (
                <tr>
                  <td
                    colSpan={6}
                    className="text-center py-16 text-ink-3 text-sm"
                  >
                    No registrations found.
                  </td>
                </tr>
              ) : (
                filtered.map((reg) => {
                  const student = Array.isArray(reg.student_profiles)
                    ? reg.student_profiles[0]
                    : reg.student_profiles;
                  const event = Array.isArray(reg.events)
                    ? reg.events[0]
                    : reg.events;
                  const dept = Array.isArray(student?.departments)
                    ? student.departments[0]
                    : student?.departments;

                  return (
                    <motion.tr
                      key={reg.id}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      className="hover:bg-fill/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2.5">
                          <div className="w-7 h-7 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xs font-bold shrink-0">
                            {student?.name ? student.name[0].toUpperCase() : "?"}
                          </div>
                          <div>
                            <p className="text-sm font-medium text-ink">
                              {student?.name || "Unknown"}
                            </p>
                            {dept && (
                              <p className="text-[10px] text-ink-3">
                                {dept.code}
                              </p>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-2">
                        {student?.roll_number || "—"}
                        {student?.enrollment_number && (
                          <span className="block text-ink-3">
                            {student.enrollment_number}
                          </span>
                        )}
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-2 max-w-[200px] hidden md:table-cell">
                        <Link
                          href={`/events/${reg.event_id}`}
                          className="hover:text-brand-blue transition-colors truncate block"
                        >
                          {event?.title || "—"}
                        </Link>
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-3 hidden lg:table-cell whitespace-nowrap">
                        {format(new Date(reg.created_at), "d MMM yyyy")}
                        <br />
                        {format(new Date(reg.created_at), "h:mm a")}
                      </td>
                      <td className="px-4 py-3">
                        <StatusBadge status={reg.status} />
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex gap-1">
                          {reg.status === "pending" && (
                            <>
                              <Button
                                size="sm"
                                variant="ghost"
                                isLoading={updating === reg.id}
                                onClick={() => updateStatus(reg.id, "approved")}
                                className="text-semantic-success hover:bg-semantic-success/10"
                                leftIcon={<CheckCircle2 size={13} />}
                              >
                                Approve
                              </Button>
                              <Button
                                size="sm"
                                variant="ghost"
                                isLoading={updating === reg.id}
                                onClick={() => updateStatus(reg.id, "rejected")}
                                className="text-semantic-danger hover:bg-semantic-danger/10"
                                leftIcon={<XCircle size={13} />}
                              >
                                Reject
                              </Button>
                            </>
                          )}
                          {reg.status === "approved" && (
                            <Button
                              size="sm"
                              variant="ghost"
                              isLoading={updating === reg.id}
                              onClick={() => updateStatus(reg.id, "rejected")}
                              className="text-semantic-danger hover:bg-semantic-danger/10"
                            >
                              Revoke
                            </Button>
                          )}
                          {reg.status === "rejected" && (
                            <Button
                              size="sm"
                              variant="ghost"
                              isLoading={updating === reg.id}
                              onClick={() => updateStatus(reg.id, "approved")}
                              className="text-semantic-success hover:bg-semantic-success/10"
                            >
                              Re-approve
                            </Button>
                          )}
                        </div>
                      </td>
                    </motion.tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

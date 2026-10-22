"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import {
  ArrowLeft,
  Search,
  Download,
  Eye,
  CheckCircle2,
  Clock,
  XCircle,
  Sparkles,
  FileSpreadsheet,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Badge } from "@/components/ui/Badge";
import { Dialog } from "@/components/ui/Dialog";
import { format } from "date-fns";

interface RegistrationItem {
  id: string;
  status: string;
  registration_number: string;
  created_at: string;
  student: {
    name?: string;
    roll_number?: string;
    enrollment_number?: string;
    phone?: string;
  };
}

interface QuestionItem {
  id: string;
  title: string;
  question_type: string;
}

interface EventResponsesClientProps {
  eventId: string;
  eventTitle: string;
  questions: QuestionItem[];
  registrations: RegistrationItem[];
  answers: Record<string, Record<string, string>>; // regId -> questionId -> answer
}

export function EventResponsesClient({
  eventId,
  eventTitle,
  questions,
  registrations,
  answers,
}: EventResponsesClientProps) {
  const [search, setSearch] = useState("");
  const [filterStatus, setFilterStatus] = useState("all");
  const [selectedReg, setSelectedReg] = useState<RegistrationItem | null>(null);

  const filtered = useMemo(() => {
    return registrations.filter((r) => {
      const matchSearch =
        !search ||
        (r.student.name || "").toLowerCase().includes(search.toLowerCase()) ||
        (r.student.roll_number || "")
          .toLowerCase()
          .includes(search.toLowerCase()) ||
        (r.registration_number || "")
          .toLowerCase()
          .includes(search.toLowerCase());

      const matchStatus =
        filterStatus === "all" || r.status === filterStatus;

      return matchSearch && matchStatus;
    });
  }, [registrations, search, filterStatus]);

  const exportCSV = () => {
    if (filtered.length === 0) {
      toast.error("No registrations to export");
      return;
    }

    const headers = [
      "Registration Number",
      "Student Name",
      "Roll Number",
      "Enrollment Number",
      "Status",
      "Submitted At",
      ...questions.map((q) => `"${q.title.replace(/"/g, '""')}"`),
    ];

    const rows = filtered.map((r) => {
      const regAnswers = answers[r.id] || {};
      const answerCols = questions.map((q) => {
        const val = regAnswers[q.id] || "";
        return `"${val.replace(/"/g, '""')}"`;
      });

      return [
        `"${r.registration_number || ""}"`,
        `"${r.student.name || ""}"`,
        `"${r.student.roll_number || ""}"`,
        `"${r.student.enrollment_number || ""}"`,
        `"${r.status}"`,
        `"${format(new Date(r.created_at), "yyyy-MM-dd HH:mm")}"`,
        ...answerCols,
      ].join(",");
    });

    const csvContent =
      "data:text/csv;charset=utf-8," + [headers.join(","), ...rows].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute(
      "download",
      `${eventTitle.replace(/[^a-zA-Z0-9]/g, "_")}_responses.csv`
    );
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    toast.success(`Exported ${filtered.length} responses to CSV`);
  };

  return (
    <div className="space-y-6 pb-20">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-line pb-4">
        <div className="flex items-center gap-3">
          <Link href={`/events/${eventId}`}>
            <button className="p-2 rounded-card hover:bg-fill transition-colors text-ink-3">
              <ArrowLeft size={18} />
            </button>
          </Link>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-ink tracking-tight">
                Form Responses
              </h1>
              <Badge variant="aqua">{registrations.length} Total</Badge>
            </div>
            <p className="text-xs text-ink-2 mt-0.5">
              Attendee submissions for:{" "}
              <span className="font-semibold text-ink">{eventTitle}</span>
            </p>
          </div>
        </div>

        <Button
          size="sm"
          onClick={exportCSV}
          leftIcon={<Download size={15} />}
          disabled={filtered.length === 0}
        >
          Export CSV ({filtered.length})
        </Button>
      </div>

      {/* Filter Bar */}
      <div className="flex flex-col sm:flex-row gap-3 items-center justify-between bg-card p-3 rounded-card border border-line">
        <div className="relative w-full sm:w-80">
          <Search
            size={15}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-ink-3"
          />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search attendee by name, roll no..."
            className="pl-9 h-9 text-xs"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto">
          {["all", "approved", "pending", "attended", "rejected"].map((s) => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              className={`px-3 py-1.5 rounded-pill text-xs font-semibold capitalize whitespace-nowrap transition-all ${
                filterStatus === s
                  ? "bg-brand-tint text-brand-blue font-bold"
                  : "text-ink-3 hover:text-ink hover:bg-fill"
              }`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="bg-card rounded-card border border-line overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-fill/60 border-b border-line text-ink-3 uppercase font-semibold tracking-wider">
              <tr>
                <th className="py-3 px-4">Attendee</th>
                <th className="py-3 px-4">Reg #</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Submitted</th>
                {questions.slice(0, 3).map((q) => (
                  <th key={q.id} className="py-3 px-4 max-w-[200px] truncate">
                    {q.title}
                  </th>
                ))}
                {questions.length > 3 && (
                  <th className="py-3 px-4 text-ink-3">
                    +{questions.length - 3} more fields
                  </th>
                )}
                <th className="py-3 px-4 text-right">View</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line/60">
              {filtered.map((r) => {
                const regAnswers = answers[r.id] || {};

                return (
                  <tr
                    key={r.id}
                    className="hover:bg-fill/40 transition-colors cursor-pointer group"
                    onClick={() => setSelectedReg(r)}
                  >
                    <td className="py-3 px-4">
                      <p className="font-semibold text-ink">
                        {r.student.name || "Unnamed"}
                      </p>
                      <p className="text-[11px] text-ink-3">
                        {r.student.roll_number || "—"}
                      </p>
                    </td>

                    <td className="py-3 px-4 font-mono text-[11px] text-ink-2">
                      {r.registration_number || "—"}
                    </td>

                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-pill text-[10px] font-semibold uppercase tracking-wider ${
                          r.status === "approved"
                            ? "bg-semantic-success-tint text-semantic-success"
                            : r.status === "attended"
                            ? "bg-brand-tint text-brand-blue"
                            : r.status === "pending"
                            ? "bg-semantic-warning-tint text-semantic-warning"
                            : "bg-semantic-danger-tint text-semantic-danger"
                        }`}
                      >
                        {r.status}
                      </span>
                    </td>

                    <td className="py-3 px-4 text-ink-3 tabular-nums">
                      {format(new Date(r.created_at), "MMM d, h:mm a")}
                    </td>

                    {questions.slice(0, 3).map((q) => (
                      <td
                        key={q.id}
                        className="py-3 px-4 text-ink max-w-[200px] truncate"
                      >
                        {regAnswers[q.id] || "—"}
                      </td>
                    ))}

                    {questions.length > 3 && (
                      <td className="py-3 px-4 text-ink-3 text-[11px]">
                        Click to view all
                      </td>
                    )}

                    <td className="py-3 px-4 text-right">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedReg(r);
                        }}
                        className="p-1.5 rounded-card hover:bg-fill text-ink-3 hover:text-ink"
                        title="View Submission"
                      >
                        <Eye size={15} />
                      </button>
                    </td>
                  </tr>
                );
              })}

              {filtered.length === 0 && (
                <tr>
                  <td
                    colSpan={5 + Math.min(questions.length, 3)}
                    className="py-12 text-center text-ink-3 text-xs"
                  >
                    No responses found matching your filter criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Response Detail Modal */}
      <Dialog
        isOpen={!!selectedReg}
        onClose={() => setSelectedReg(null)}
        title={
          selectedReg
            ? `${selectedReg.student.name || "Attendee"} — Response Details`
            : "Response Details"
        }
      >
        {selectedReg && (
          <div className="space-y-4 pt-2">
            <div className="grid grid-cols-2 gap-3 p-3 bg-fill rounded-card text-xs">
              <div>
                <span className="text-ink-3 block">Roll Number:</span>
                <span className="font-semibold text-ink">
                  {selectedReg.student.roll_number || "—"}
                </span>
              </div>
              <div>
                <span className="text-ink-3 block">Reg Number:</span>
                <span className="font-mono text-ink">
                  {selectedReg.registration_number || "—"}
                </span>
              </div>
              <div>
                <span className="text-ink-3 block">Status:</span>
                <span className="font-semibold uppercase tracking-wider text-ink">
                  {selectedReg.status}
                </span>
              </div>
              <div>
                <span className="text-ink-3 block">Submission Date:</span>
                <span className="text-ink">
                  {format(new Date(selectedReg.created_at), "PPp")}
                </span>
              </div>
            </div>

            <div className="space-y-3 pt-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-ink-3">
                Question Responses
              </h4>

              {questions.length === 0 ? (
                <p className="text-xs text-ink-3 italic">
                  No custom questions were attached to this registration form.
                </p>
              ) : (
                <div className="space-y-3">
                  {questions.map((q) => {
                    const answerVal =
                      answers[selectedReg.id]?.[q.id] || "No response provided";

                    return (
                      <div
                        key={q.id}
                        className="p-3 rounded-card border border-line bg-card space-y-1"
                      >
                        <p className="text-xs font-semibold text-ink">
                          {q.title}
                        </p>
                        <p className="text-xs text-ink-2 bg-fill/50 p-2 rounded">
                          {answerVal}
                        </p>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        )}
      </Dialog>
    </div>
  );
}

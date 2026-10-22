"use client";

import React, { useState, useMemo } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from "recharts";
import { Download, BarChart3, Star, Users, Calendar } from "lucide-react";
import { StatCard } from "@/components/ui/StatCard";
import { Select } from "@/components/ui/Select";
import { Button } from "@/components/ui/Button";
import { format } from "date-fns";

const CHART_COLORS = [
  "#0AA5F0",
  "#38BDF8",
  "#6CE3FF",
  "#8E8BEA",
  "#3DDC97",
  "#FFD84D",
  "#FF6B8A",
  "#0063F0",
];

interface ReportsClientProps {
  events: any[];
  platformStats: {
    totalEvents: number;
    totalStudents: number;
    totalRegistrations: number;
    totalAttendance: number;
  };
  regByEvent: any[];
  studentsByDept: any[];
  allFeedback: any[];
  preSelectedEvent: string | null;
}

export function ReportsClient({
  events,
  platformStats,
  regByEvent,
  studentsByDept,
  allFeedback,
  preSelectedEvent,
}: ReportsClientProps) {
  const [selectedEvent, setSelectedEvent] = useState(
    preSelectedEvent || "all"
  );

  const attendanceRate =
    platformStats.totalRegistrations > 0
      ? Math.round(
          (platformStats.totalAttendance / platformStats.totalRegistrations) *
            100
        )
      : 0;

  // Registrations per event chart data
  const regChartData = useMemo(() => {
    const counts: Record<string, { title: string; count: number }> = {};
    regByEvent.forEach((r) => {
      const ev = Array.isArray(r.events) ? r.events[0] : r.events;
      if (!counts[r.event_id]) {
        counts[r.event_id] = { title: ev?.title || "Unknown", count: 0 };
      }
      counts[r.event_id].count++;
    });
    return Object.values(counts)
      .sort((a, b) => b.count - a.count)
      .slice(0, 10)
      .map((d) => ({
        name:
          d.title.length > 18 ? d.title.slice(0, 18) + "…" : d.title,
        count: d.count,
      }));
  }, [regByEvent]);

  // Students by department chart data
  const deptChartData = useMemo(() => {
    const counts: Record<string, { name: string; count: number }> = {};
    studentsByDept.forEach((s) => {
      const dept = Array.isArray(s.departments) ? s.departments[0] : s.departments;
      const key = dept?.code || "Unknown";
      if (!counts[key]) counts[key] = { name: dept?.name || key, count: 0 };
      counts[key].count++;
    });
    return Object.entries(counts)
      .map(([code, d]) => ({ name: code, fullName: d.name, count: d.count }))
      .sort((a, b) => b.count - a.count);
  }, [studentsByDept]);

  // Feedback rating distribution
  const ratingDist = useMemo(() => {
    const dist: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    allFeedback.forEach((f) => {
      const r = Math.round(f.rating);
      if (r >= 1 && r <= 5) dist[r]++;
    });
    return [5, 4, 3, 2, 1].map((r) => ({
      name: `${r}★`,
      count: dist[r],
    }));
  }, [allFeedback]);

  const avgRating =
    allFeedback.length > 0
      ? (
          allFeedback.reduce((sum, f) => sum + f.rating, 0) /
          allFeedback.length
        ).toFixed(1)
      : "—";

  const exportReport = () => {
    const lines = [
      "ZEST Admin — Platform Report",
      `Generated: ${format(new Date(), "d MMM yyyy h:mm a")}`,
      "",
      "Platform Statistics",
      `Total Events: ${platformStats.totalEvents}`,
      `Total Students: ${platformStats.totalStudents}`,
      `Total Registrations: ${platformStats.totalRegistrations}`,
      `Total Attendances: ${platformStats.totalAttendance}`,
      `Attendance Rate: ${attendanceRate}%`,
      `Average Rating: ${avgRating}`,
      "",
      "Registrations by Event",
      ...regChartData.map((d) => `  ${d.name}: ${d.count}`),
      "",
      "Students by Department",
      ...deptChartData.map((d) => `  ${d.name}: ${d.count}`),
    ];
    const blob = new Blob([lines.join("\n")], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `zest-report-${new Date().toISOString().slice(0, 10)}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            <span className="serif-accent font-normal text-brand-blue">
              Insights
            </span>{" "}
            &amp; Reports
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            Platform analytics and accreditation data.
          </p>
        </div>
        <Button
          variant="outline"
          leftIcon={<Download size={15} />}
          onClick={exportReport}
        >
          Export Report
        </Button>
      </div>

      {/* Platform Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard
          label="Total Events"
          value={platformStats.totalEvents}
          icon={<Calendar size={16} />}
          color="brand"
        />
        <StatCard
          label="Students"
          value={platformStats.totalStudents}
          icon={<Users size={16} />}
          color="default"
        />
        <StatCard
          label="Registrations"
          value={platformStats.totalRegistrations}
          icon={<BarChart3 size={16} />}
          color="warning"
        />
        <StatCard
          label="Attendance Rate"
          value={`${attendanceRate}%`}
          icon={<Star size={16} />}
          color="success"
          sub={`${platformStats.totalAttendance} check-ins`}
        />
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Registrations by Event */}
        <div className="bg-card rounded-card border border-line p-6">
          <h2 className="text-base font-semibold text-ink mb-4">
            Registrations by Event{" "}
            <span className="text-xs text-ink-3 font-normal">(Top 10)</span>
          </h2>
          {regChartData.length === 0 ? (
            <div className="h-48 flex items-center justify-center text-ink-3 text-sm">
              No data yet.
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={260}>
              <BarChart
                data={regChartData}
                layout="vertical"
                margin={{ left: 0, right: 16, top: 0, bottom: 0 }}
              >
                <XAxis type="number" tick={{ fontSize: 11, fill: "#8A93A5" }} />
                <YAxis
                  dataKey="name"
                  type="category"
                  width={120}
                  tick={{ fontSize: 10, fill: "#5B6577" }}
                />
                <Tooltip
                  contentStyle={{
                    background: "#fff",
                    border: "1px solid #E6EAF2",
                    borderRadius: 8,
                    fontSize: 12,
                  }}
                />
                <Bar
                  dataKey="count"
                  fill="#0AA5F0"
                  radius={[0, 4, 4, 0]}
                  name="Registrations"
                />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Students by Department */}
        <div className="bg-card rounded-card border border-line p-6">
          <h2 className="text-base font-semibold text-ink mb-4">
            Students by Department
          </h2>
          {deptChartData.length === 0 ? (
            <div className="h-48 flex items-center justify-center text-ink-3 text-sm">
              No data yet.
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie
                  data={deptChartData}
                  dataKey="count"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  outerRadius={90}
                  label={({ name, percent }) =>
                    `${name} ${(percent * 100).toFixed(0)}%`
                  }
                  labelLine={false}
                >
                  {deptChartData.map((_, idx) => (
                    <Cell
                      key={idx}
                      fill={CHART_COLORS[idx % CHART_COLORS.length]}
                    />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(v: any, name: any, props: any) => [
                    `${v} students`,
                    props.payload.fullName || name,
                  ]}
                  contentStyle={{
                    background: "#fff",
                    border: "1px solid #E6EAF2",
                    borderRadius: 8,
                    fontSize: 12,
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Rating Distribution */}
        <div className="bg-card rounded-card border border-line p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-base font-semibold text-ink">
              Feedback Ratings
            </h2>
            <div className="flex items-center gap-1.5 bg-brand-tint rounded-pill px-3 py-1">
              <Star size={14} className="text-accent-lemon fill-accent-lemon" />
              <span className="text-sm font-bold text-brand-blue">
                {avgRating}
              </span>
              <span className="text-xs text-ink-3">
                avg · {allFeedback.length} responses
              </span>
            </div>
          </div>
          {allFeedback.length === 0 ? (
            <div className="h-48 flex items-center justify-center text-ink-3 text-sm">
              No feedback yet.
            </div>
          ) : (
            <div className="space-y-3">
              {ratingDist.map((r) => {
                const pct =
                  allFeedback.length > 0
                    ? Math.round((r.count / allFeedback.length) * 100)
                    : 0;
                return (
                  <div key={r.name} className="flex items-center gap-3">
                    <span className="text-xs font-medium text-ink-2 w-6">
                      {r.name}
                    </span>
                    <div className="flex-1 h-2.5 bg-fill rounded-full overflow-hidden">
                      <div
                        className="h-full bg-brand-core rounded-full transition-all duration-500"
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                    <span className="text-xs text-ink-3 w-10 text-right tabular-nums">
                      {r.count}
                    </span>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Summary Card for Accreditation */}
        <div className="bg-gradient-to-br from-brand-tint to-white rounded-card border border-brand-sky/20 p-6 relative overflow-hidden">
          <div className="absolute -right-8 -bottom-8 w-32 h-32 rounded-full bg-brand-sky/20 blur-3xl" />
          <h2 className="text-base font-semibold text-ink mb-2">
            Accreditation Summary
          </h2>
          <p className="text-xs text-ink-2 mb-5">
            Key metrics for university reporting (NAAC / NBA).
          </p>
          <div className="space-y-3">
            {[
              ["Total Events Conducted", platformStats.totalEvents],
              ["Student Participation (unique)", platformStats.totalStudents],
              ["Total Registrations Filed", platformStats.totalRegistrations],
              ["Attendance Records", platformStats.totalAttendance],
              ["Overall Attendance Rate", `${attendanceRate}%`],
              ["Average Event Rating", avgRating],
              ["Feedback Responses", allFeedback.length],
            ].map(([label, value]) => (
              <div
                key={label as string}
                className="flex items-center justify-between"
              >
                <span className="text-xs text-ink-2">{label}</span>
                <span className="text-sm font-bold text-ink tabular-nums">
                  {value}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

"use client";

import React, { useState, useMemo } from "react";
import { motion } from "framer-motion";
import { Search, GraduationCap, Download, Trophy, Star } from "lucide-react";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { Badge } from "@/components/ui/Badge";

interface StudentsClientProps {
  students: any[];
  departments: any[];
}

export function StudentsClient({ students, departments }: StudentsClientProps) {
  const [search, setSearch] = useState("");
  const [filterDept, setFilterDept] = useState("all");
  const [filterYear, setFilterYear] = useState("all");
  const [sortBy, setSortBy] = useState<"name" | "points" | "score">("name");

  const filtered = useMemo(() => {
    let data = students.filter((s) => {
      const dept = Array.isArray(s.departments) ? s.departments[0] : s.departments;
      const q = search.toLowerCase();
      const matchSearch =
        !q ||
        s.name.toLowerCase().includes(q) ||
        (s.roll_number || "").toLowerCase().includes(q) ||
        (s.enrollment_number || "").toLowerCase().includes(q) ||
        (dept?.name || "").toLowerCase().includes(q);
      const matchDept = filterDept === "all" || s.department_id === filterDept;
      const matchYear = filterYear === "all" || String(s.year) === filterYear;
      return matchSearch && matchDept && matchYear;
    });

    data.sort((a, b) => {
      if (sortBy === "points") return (b.points || 0) - (a.points || 0);
      if (sortBy === "score")
        return (
          (b.participation_score || 0) + (b.volunteer_score || 0) -
          ((a.participation_score || 0) + (a.volunteer_score || 0))
        );
      return a.name.localeCompare(b.name);
    });
    return data;
  }, [students, search, filterDept, filterYear, sortBy]);

  const exportCSV = () => {
    const rows = filtered.map((s) => {
      const dept = Array.isArray(s.departments) ? s.departments[0] : s.departments;
      return [
        s.name,
        s.roll_number || "",
        s.enrollment_number || "",
        dept?.name || "",
        dept?.code || "",
        s.year || "",
        s.semester || "",
        s.division || "",
        s.gender || "",
        s.points || 0,
        s.participation_score || 0,
        s.volunteer_score || 0,
      ];
    });
    const header = [
      "Name",
      "Roll No",
      "Enrollment",
      "Department",
      "Dept Code",
      "Year",
      "Semester",
      "Division",
      "Gender",
      "Points",
      "Participation Score",
      "Volunteer Score",
    ];
    const csv = [header, ...rows]
      .map((r) => r.map((v) => `"${v}"`).join(","))
      .join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `students-${new Date().toISOString().slice(0, 10)}.csv`;
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
              Students
            </span>
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            {filtered.length} of {students.length} students
          </p>
        </div>
        <button
          onClick={exportCSV}
          className="flex items-center gap-2 text-sm font-medium text-ink-2 hover:text-ink px-4 py-2 rounded-card border border-line bg-card hover:bg-fill transition-colors"
        >
          <Download size={15} />
          Export CSV
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex-1">
          <Input
            placeholder="Search by name, roll, enrollment…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            leftIcon={<Search size={15} />}
          />
        </div>
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
        <Select
          value={filterYear}
          onChange={(e) => setFilterYear(e.target.value)}
          className="sm:w-28"
        >
          <option value="all">All years</option>
          {[1, 2, 3, 4].map((y) => (
            <option key={y} value={String(y)}>
              Year {y}
            </option>
          ))}
        </Select>
        <Select
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value as any)}
          className="sm:w-36"
        >
          <option value="name">Sort: Name</option>
          <option value="points">Sort: Points</option>
          <option value="score">Sort: Score</option>
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
                  Dept
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider hidden lg:table-cell">
                  Year · Sem
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider">
                  <Trophy size={12} className="inline mr-1" />
                  Points
                </th>
                <th className="px-4 py-3 text-xs font-semibold text-ink-2 uppercase tracking-wider hidden xl:table-cell">
                  <Star size={12} className="inline mr-1" />
                  Score
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
                    No students found.
                  </td>
                </tr>
              ) : (
                filtered.map((student, i) => {
                  const dept = Array.isArray(student.departments)
                    ? student.departments[0]
                    : student.departments;
                  return (
                    <motion.tr
                      key={student.id}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: i * 0.02 }}
                      className="hover:bg-fill/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2.5">
                          <div className="w-8 h-8 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xs font-bold shrink-0">
                            {student.name[0].toUpperCase()}
                          </div>
                          <div>
                            <p className="text-sm font-medium text-ink">
                              {student.name}
                            </p>
                            {student.gender && (
                              <p className="text-[10px] text-ink-3 capitalize">
                                {student.gender}
                              </p>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-2">
                        {student.roll_number || "—"}
                        {student.enrollment_number && (
                          <span className="block text-ink-3 text-[10px]">
                            {student.enrollment_number}
                          </span>
                        )}
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-2 hidden md:table-cell">
                        {dept ? (
                          <span className="inline-flex items-center gap-1 bg-fill px-2 py-0.5 rounded-full text-[11px] font-medium">
                            {dept.code}
                          </span>
                        ) : (
                          "—"
                        )}
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-2 hidden lg:table-cell">
                        {student.year ? `Y${student.year}` : "—"}
                        {student.semester ? ` · S${student.semester}` : ""}
                        {student.division ? ` · Div ${student.division}` : ""}
                      </td>
                      <td className="px-4 py-3">
                        <span className="text-sm font-bold text-brand-blue tabular-nums">
                          {student.points || 0}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-xs text-ink-2 hidden xl:table-cell tabular-nums">
                        P: {student.participation_score || 0} · V:{" "}
                        {student.volunteer_score || 0}
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

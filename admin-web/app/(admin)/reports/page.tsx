import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { ReportsClient } from "./ReportsClient";

export const metadata = {
  title: "Reports — ZEST Admin",
  description: "Analytics, insights, and exports",
};

export default async function ReportsPage({
  searchParams,
}: {
  searchParams: { event?: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const { data: events } = await supabase
    .from("events")
    .select("id, title, start_date, visibility")
    .order("start_date", { ascending: false });

  // Platform-wide stats
  const [
    { count: totalEvents },
    { count: totalStudents },
    { count: totalRegistrations },
    { count: totalAttendance },
  ] = await Promise.all([
    supabase.from("events").select("*", { count: "exact", head: true }),
    supabase.from("student_profiles").select("*", { count: "exact", head: true }),
    supabase.from("registrations").select("*", { count: "exact", head: true }),
    supabase.from("attendance").select("*", { count: "exact", head: true }),
  ]);

  // Registrations per event (top 10)
  const { data: regByEvent } = await supabase
    .from("registrations")
    .select("event_id, events(title)")
    .limit(500);

  // Department breakdown
  const { data: studentsByDept } = await supabase
    .from("student_profiles")
    .select("department_id, departments(name, code)");

  // Feedback overview
  const { data: allFeedback } = await supabase
    .from("event_feedback")
    .select("rating, event_id, events(title)");

  return (
    <ReportsClient
      events={(events as any[]) ?? []}
      platformStats={{
        totalEvents: totalEvents ?? 0,
        totalStudents: totalStudents ?? 0,
        totalRegistrations: totalRegistrations ?? 0,
        totalAttendance: totalAttendance ?? 0,
      }}
      regByEvent={(regByEvent as any[]) ?? []}
      studentsByDept={(studentsByDept as any[]) ?? []}
      allFeedback={(allFeedback as any[]) ?? []}
      preSelectedEvent={searchParams.event || null}
    />
  );
}

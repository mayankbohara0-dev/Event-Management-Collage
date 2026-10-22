import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { DashboardClient } from "./DashboardClient";

export const metadata = {
  title: "Dashboard — ZEST Admin",
  description: "Overview of campus events, registrations, and attendance",
};

export default async function DashboardPage() {
  const supabase = createClient();

  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (!session) redirect("/login");

  // Fetch aggregate stats
  const [
    { count: totalEvents },
    { count: publishedEvents },
    { count: totalRegistrations },
    { count: pendingRegistrations },
    { count: attendanceCount },
    { count: totalStudents },
  ] = await Promise.all([
    supabase.from("events").select("*", { count: "exact", head: true }),
    supabase
      .from("events")
      .select("*", { count: "exact", head: true })
      .eq("visibility", "published"),
    supabase
      .from("registrations")
      .select("*", { count: "exact", head: true }),
    supabase
      .from("registrations")
      .select("*", { count: "exact", head: true })
      .eq("status", "pending"),
    supabase.from("attendance").select("*", { count: "exact", head: true }),
    supabase
      .from("student_profiles")
      .select("*", { count: "exact", head: true }),
  ]);

  // Recent events
  const { data: recentEvents } = await supabase
    .from("events")
    .select("id, title, start_date, end_date, visibility, venue")
    .order("created_at", { ascending: false })
    .limit(5);

  // Upcoming events (next 30 days)
  const now = new Date().toISOString();
  const in30 = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();
  const { data: upcomingEvents } = await supabase
    .from("events")
    .select("id, title, start_date, venue, visibility")
    .eq("visibility", "published")
    .gte("start_date", now)
    .lte("start_date", in30)
    .order("start_date", { ascending: true })
    .limit(6);

  // Recent registrations
  const { data: recentRegs } = await supabase
    .from("registrations")
    .select(
      "id, status, created_at, student_id, event_id, events(title), student_profiles(name, roll_number)"
    )
    .order("created_at", { ascending: false })
    .limit(8);

  const stats = {
    totalEvents: totalEvents ?? 0,
    publishedEvents: publishedEvents ?? 0,
    totalRegistrations: totalRegistrations ?? 0,
    pendingRegistrations: pendingRegistrations ?? 0,
    attendanceCount: attendanceCount ?? 0,
    totalStudents: totalStudents ?? 0,
  };

  return (
    <DashboardClient
      stats={stats}
      recentEvents={(recentEvents as any[]) ?? []}
      upcomingEvents={(upcomingEvents as any[]) ?? []}
      recentRegistrations={(recentRegs as any[]) ?? []}
    />
  );
}

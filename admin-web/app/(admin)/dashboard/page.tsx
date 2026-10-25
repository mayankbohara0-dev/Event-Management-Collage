import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { DashboardClient } from "./DashboardClient";

export const metadata = {
  title: "Dashboard — ZEST Admin",
  description: "Overview of campus events, registrations, and attendance",
};

export const revalidate = 10; // Cache for 10s to speed up frequent page transitions

export default async function DashboardPage() {
  const supabase = createClient();

  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (!session) redirect("/login");

  // Fast path: Try single-query RPC function (executes in PostgreSQL in <10ms)
  try {
    const { data: summary, error: rpcError } = await (supabase.rpc as any)(
      "get_dashboard_summary"
    );

    if (!rpcError && summary) {
      const stats = {
        totalEvents: summary.totalEvents ?? 0,
        publishedEvents: summary.publishedEvents ?? 0,
        totalRegistrations: summary.totalRegistrations ?? 0,
        pendingRegistrations: summary.pendingRegistrations ?? 0,
        attendanceCount: summary.attendanceCount ?? 0,
        totalStudents: summary.totalStudents ?? 0,
      };

      return (
        <DashboardClient
          stats={stats}
          recentEvents={(summary.recentEvents as any[]) ?? []}
          upcomingEvents={(summary.upcomingEvents as any[]) ?? []}
          recentRegistrations={(summary.recentRegistrations as any[]) ?? []}
        />
      );
    }
  } catch {
    // Graceful fallback to parallel queries below
  }

  // Fallback path: Run ALL count and list queries in a single parallel batch
  const now = new Date().toISOString();
  const in30 = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();

  const [
    { count: totalEvents },
    { count: publishedEvents },
    { count: totalRegistrations },
    { count: pendingRegistrations },
    { count: attendanceCount },
    { count: totalStudents },
    { data: recentEvents },
    { data: upcomingEvents },
    { data: recentRegs },
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
    supabase
      .from("events")
      .select("id, title, start_date, end_date, visibility, venue")
      .order("created_at", { ascending: false })
      .limit(5),
    supabase
      .from("events")
      .select("id, title, start_date, venue, visibility")
      .eq("visibility", "published")
      .gte("start_date", now)
      .lte("start_date", in30)
      .order("start_date", { ascending: true })
      .limit(6),
    supabase
      .from("registrations")
      .select(
        "id, status, created_at, student_id, event_id, events(title), student_profiles(name, roll_number)"
      )
      .order("created_at", { ascending: false })
      .limit(8),
  ]);

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

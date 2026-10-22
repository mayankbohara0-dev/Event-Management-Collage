import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect, notFound } from "next/navigation";
import { EventDetailClient } from "./EventDetailClient";

export async function generateMetadata({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data } = await (supabase
    .from("events") as any)
    .select("title")
    .eq("id", params.id)
    .maybeSingle();
  const event = data as any;
  return {
    title: event?.title ? `${event.title} — ZEST Admin` : "Event — ZEST Admin",
  };
}

export default async function EventDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const { data: event } = await supabase
    .from("events")
    .select(
      "*, departments(name, code), event_categories(name)"
    )
    .eq("id", params.id)
    .maybeSingle();

  if (!event) notFound();

  // Registration stats
  const [
    { count: totalReg },
    { count: approvedReg },
    { count: pendingReg },
    { count: checkedIn },
  ] = await Promise.all([
    supabase
      .from("registrations")
      .select("*", { count: "exact", head: true })
      .eq("event_id", params.id),
    supabase
      .from("registrations")
      .select("*", { count: "exact", head: true })
      .eq("event_id", params.id)
      .eq("status", "approved"),
    supabase
      .from("registrations")
      .select("*", { count: "exact", head: true })
      .eq("event_id", params.id)
      .eq("status", "pending"),
    supabase
      .from("attendance")
      .select("*", { count: "exact", head: true })
      .eq("event_id", params.id),
  ]);

  // Feedback stats
  const { data: feedbackData } = await supabase
    .from("event_feedback")
    .select("rating")
    .eq("event_id", params.id);

  const fbList = (feedbackData as any[]) || [];
  const avgRating =
    fbList.length > 0
      ? fbList.reduce((sum: number, f: any) => sum + (f.rating || 0), 0) / fbList.length
      : null;

  // Recent registrations for this event
  const { data: recentRegistrations } = await supabase
    .from("registrations")
    .select(
      "id, status, created_at, registration_number, student_profiles(name, roll_number, department_id)"
    )
    .eq("event_id", params.id)
    .order("created_at", { ascending: false })
    .limit(10);

  return (
    <EventDetailClient
      event={event as any}
      stats={{
        totalReg: totalReg ?? 0,
        approvedReg: approvedReg ?? 0,
        pendingReg: pendingReg ?? 0,
        checkedIn: checkedIn ?? 0,
        avgRating,
        feedbackCount: feedbackData?.length ?? 0,
      }}
      recentRegistrations={(recentRegistrations as any[]) ?? []}
    />
  );
}

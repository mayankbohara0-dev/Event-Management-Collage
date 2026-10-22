import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { CheckinClient } from "./CheckinClient";

export const metadata = {
  title: "Check-in Scanner — ZEST Admin",
  description: "Live QR code attendance scanner",
};

export default async function CheckinPage({
  searchParams,
}: {
  searchParams: { event?: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  // Load all published events for event selector
  const { data: events } = await supabase
    .from("events")
    .select("id, title, start_date, end_date, venue")
    .in("visibility", ["published"])
    .order("start_date", { ascending: false });

  // If a specific event is pre-selected, load its check-in stats
  const selectedEventId = searchParams.event || null;

  let checkinStats = null;
  if (selectedEventId) {
    const [{ count: totalReg }, { count: checkedIn }] = await Promise.all([
      supabase
        .from("registrations")
        .select("*", { count: "exact", head: true })
        .eq("event_id", selectedEventId)
        .eq("status", "approved"),
      supabase
        .from("attendance")
        .select("*", { count: "exact", head: true })
        .eq("event_id", selectedEventId),
    ]);
    checkinStats = {
      totalApproved: totalReg ?? 0,
      checkedIn: checkedIn ?? 0,
    };
  }

  return (
    <CheckinClient
      events={(events as any[]) ?? []}
      preSelectedEventId={selectedEventId}
      initialStats={checkinStats}
      adminId={session.user.id}
    />
  );
}

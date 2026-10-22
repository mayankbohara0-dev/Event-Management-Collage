import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { FeedbackClient } from "./FeedbackClient";

export const metadata = {
  title: "Feedback — ZEST Admin",
  description: "Event feedback and ratings",
};

export default async function FeedbackPage({
  searchParams,
}: {
  searchParams: { event?: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: feedback }, { data: events }] = await Promise.all([
    supabase
      .from("event_feedback")
      .select(
        "id, rating, review, created_at, event_id, student_id, events(title), student_profiles(name, roll_number)"
      )
      .order("created_at", { ascending: false })
      .limit(200),
    supabase
      .from("events")
      .select("id, title")
      .order("start_date", { ascending: false }),
  ]);

  return (
    <FeedbackClient
      feedback={(feedback as any[]) ?? []}
      events={(events as any[]) ?? []}
      preFilterEvent={searchParams.event || null}
    />
  );
}

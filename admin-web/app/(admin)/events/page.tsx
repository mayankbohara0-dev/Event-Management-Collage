import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { EventsClient } from "./EventsClient";

export const metadata = {
  title: "Events — ZEST Admin",
  description: "Manage all campus events",
};

export default async function EventsPage() {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: events }, { data: categories }, { data: departments }] =
    await Promise.all([
      supabase
        .from("events")
        .select(
          "id, title, short_description, start_date, end_date, visibility, venue, tags, banner_url, max_seats, created_at, department_id, category_id, departments(name, code), event_categories(name)"
        )
        .order("start_date", { ascending: false }),
      supabase.from("event_categories").select("id, name").order("name"),
      supabase
        .from("departments")
        .select("id, name, code")
        .order("name"),
    ]);

  return (
    <EventsClient
      initialEvents={(events as any[]) ?? []}
      categories={(categories as any[]) ?? []}
      departments={(departments as any[]) ?? []}
    />
  );
}

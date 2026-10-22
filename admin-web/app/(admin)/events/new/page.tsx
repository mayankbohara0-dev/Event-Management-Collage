import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { EventFormClient } from "../EventFormClient";

export const metadata = {
  title: "New Event — ZEST Admin",
  description: "Create a new campus event",
};

export default async function NewEventPage() {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: categories }, { data: departments }] = await Promise.all([
    supabase.from("event_categories").select("id, name").order("name"),
    supabase.from("departments").select("id, name, code").order("name"),
  ]);

  return (
    <EventFormClient
      mode="create"
      event={null}
      categories={(categories as any[]) ?? []}
      departments={(departments as any[]) ?? []}
      adminId={session.user.id}
    />
  );
}

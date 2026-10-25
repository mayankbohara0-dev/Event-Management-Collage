import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { RegistrationsClient } from "./RegistrationsClient";

export const metadata = {
  title: "Registrations — ZEST Admin",
  description: "Manage all event registrations",
};

export const revalidate = 15;

export default async function RegistrationsPage({
  searchParams,
}: {
  searchParams: { event?: string; status?: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  let query = supabase
    .from("registrations")
    .select(
      "id, status, registration_number, created_at, updated_at, event_id, student_id, events(id, title, start_date), student_profiles(id, name, roll_number, enrollment_number, department_id, departments(name, code))"
    )
    .order("created_at", { ascending: false })
    .limit(200);

  if (searchParams.event) {
    query = query.eq("event_id", searchParams.event) as any;
  }
  if (
    searchParams.status &&
    ["pending", "approved", "rejected", "waitlisted"].includes(
      searchParams.status
    )
  ) {
    query = query.eq("status", searchParams.status) as any;
  }

  const { data: registrations } = await query;

  const { data: events } = await supabase
    .from("events")
    .select("id, title")
    .order("start_date", { ascending: false })
    .limit(100);

  return (
    <RegistrationsClient
      initialRegistrations={(registrations as any[]) ?? []}
      events={(events as any[]) ?? []}
      preFilterEvent={searchParams.event || null}
      preFilterStatus={searchParams.status || null}
    />
  );
}

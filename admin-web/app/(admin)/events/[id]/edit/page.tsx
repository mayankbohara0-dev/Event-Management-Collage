import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect, notFound } from "next/navigation";
import { EventFormClient } from "../../EventFormClient";

export const metadata = {
  title: "Edit Event — ZEST Admin",
};

export default async function EditEventPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: event }, { data: categories }, { data: departments }] =
    await Promise.all([
      supabase.from("events").select("*").eq("id", params.id).maybeSingle(),
      supabase.from("event_categories").select("id, name").order("name"),
      supabase.from("departments").select("id, name, code").order("name"),
    ]);

  if (!event) notFound();

  return (
    <EventFormClient
      mode="edit"
      event={event as any}
      categories={(categories as any[]) ?? []}
      departments={(departments as any[]) ?? []}
      adminId={session.user.id}
    />
  );
}

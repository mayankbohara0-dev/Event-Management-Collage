import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { TeamClient } from "./TeamClient";

export const metadata = {
  title: "Team — ZEST Admin",
  description: "Manage organizer team members",
};

export default async function TeamPage() {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: team }, { data: departments }] = await Promise.all([
    supabase
      .from("admin_profiles")
      .select(
        "id, name, role, avatar_url, created_at, department_id, departments(name, code)"
      )
      .order("name"),
    supabase.from("departments").select("id, name, code").order("name"),
  ]);

  // Get emails from auth (we only have the current user's email easily)
  const currentUserId = session.user.id;

  return (
    <TeamClient
      team={(team as any[]) ?? []}
      departments={(departments as any[]) ?? []}
      currentUserId={currentUserId}
    />
  );
}

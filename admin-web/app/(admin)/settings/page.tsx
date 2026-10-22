import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { SettingsClient } from "./SettingsClient";

export const metadata = {
  title: "Settings — ZEST Admin",
  description: "Admin account and platform settings",
};

export default async function SettingsPage() {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const { data: profile } = await supabase
    .from("admin_profiles")
    .select("id, name, role, avatar_url, department_id, departments(name, code)")
    .eq("id", session.user.id)
    .maybeSingle();

  return (
    <SettingsClient
      profile={profile as any}
      email={session.user.email || ""}
    />
  );
}

import React from "react";
import { redirect } from "next/navigation";
import { AppShell } from "@/components/shell/AppShell";
import { createClient } from "@/lib/supabase/server";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createClient();

  const {
    data: { session },
  } = await supabase.auth.getSession();

  let adminProfile: {
    name: string;
    role: string;
    email?: string;
    avatarUrl?: string;
  } = {
    name: "Organizer",
    role: "admin",
  };

  if (session?.user) {
    const { data: profile } = await supabase
      .from("admin_profiles")
      .select("name, role, avatar_url")
      .eq("id", session.user.id)
      .maybeSingle();

    if (profile) {
      const p = profile as {
        name: string;
        role: string;
        avatar_url: string | null;
      };
      adminProfile = {
        name: p.name,
        role: p.role,
        email: session.user.email,
        avatarUrl: p.avatar_url || undefined,
      };
    }
  }

  return (
    <AppShell user={adminProfile}>
      {children}
    </AppShell>
  );
}

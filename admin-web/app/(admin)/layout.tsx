import React, { cache } from "react";
import { redirect } from "next/navigation";
import { AppShell } from "@/components/shell/AppShell";
import { createClient } from "@/lib/supabase/server";

const getAdminProfile = cache(async (userId: string) => {
  const supabase = createClient();
  const { data: profile } = await supabase
    .from("admin_profiles")
    .select("name, role, avatar_url")
    .eq("id", userId)
    .maybeSingle();
  return profile;
});

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createClient();

  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (!session) {
    redirect("/login");
  }

  let adminProfile: {
    name: string;
    role: string;
    email?: string;
    avatarUrl?: string;
  } = {
    name: "Organizer",
    role: "admin",
    email: session.user.email,
  };

  const profile = await getAdminProfile(session.user.id);
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

  return (
    <AppShell user={adminProfile}>
      {children}
    </AppShell>
  );
}

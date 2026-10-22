import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { DepartmentsClient } from "./DepartmentsClient";

export const metadata = {
  title: "Departments — ZEST Admin",
  description: "Manage university departments",
};

export default async function DepartmentsPage() {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: departments }, { data: studentCounts }] = await Promise.all([
    supabase
      .from("departments")
      .select("id, name, code, created_at")
      .order("name"),
    supabase
      .from("student_profiles")
      .select("department_id"),
  ]);

  // Count students per dept
  const countMap: Record<string, number> = {};
  ((studentCounts as any[]) || []).forEach((s: any) => {
    if (s.department_id) {
      countMap[s.department_id] = (countMap[s.department_id] || 0) + 1;
    }
  });

  return (
    <DepartmentsClient
      departments={(departments as any[]) ?? []}
      studentCountByDept={countMap}
    />
  );
}

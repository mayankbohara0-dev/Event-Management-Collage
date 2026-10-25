import React from "react";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { StudentsClient } from "./StudentsClient";

export const metadata = {
  title: "Students — ZEST Admin",
  description: "Student directory",
};

export const revalidate = 30;

export default async function StudentsPage() {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  const [{ data: students }, { data: departments }] = await Promise.all([
    supabase
      .from("student_profiles")
      .select(
        "id, name, roll_number, enrollment_number, year, semester, division, gender, participation_score, volunteer_score, points, department_id, departments(name, code)"
      )
      .order("name"),
    supabase.from("departments").select("id, name, code").order("name"),
  ]);

  return (
    <StudentsClient
      students={(students as any[]) ?? []}
      departments={(departments as any[]) ?? []}
    />
  );
}

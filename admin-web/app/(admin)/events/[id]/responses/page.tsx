import React from "react";
import { createClient } from "@/lib/supabase/server";
import { notFound, redirect } from "next/navigation";
import { EventResponsesClient } from "./EventResponsesClient";

export async function generateMetadata({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data } = await (supabase.from("events") as any)
    .select("title")
    .eq("id", params.id)
    .maybeSingle();

  return {
    title: `Responses — ${data?.title || "Event"} — ZEST Admin`,
  };
}

export default async function EventResponsesPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) redirect("/login");

  // 1. Get Event
  const { data: event } = await (supabase.from("events") as any)
    .select("id, title")
    .eq("id", params.id)
    .maybeSingle();

  if (!event) notFound();

  // 2. Get questions for this event form
  const { data: form } = await (supabase.from("registration_forms") as any)
    .select("id, form_sections(form_questions(id, title, question_type, order_index))")
    .eq("event_id", params.id)
    .maybeSingle();

  const questions: Array<{ id: string; title: string; question_type: string }> = [];
  if (form?.form_sections) {
    for (const section of form.form_sections) {
      if (section.form_questions) {
        for (const q of section.form_questions) {
          questions.push({
            id: q.id,
            title: q.title,
            question_type: q.question_type,
          });
        }
      }
    }
  }

  // 3. Get registrations
  const { data: rawRegs } = await (supabase.from("registrations") as any)
    .select(
      "id, status, registration_number, created_at, student_profiles(name, roll_number, enrollment_number, phone)"
    )
    .eq("event_id", params.id)
    .order("created_at", { ascending: false });

  const registrations = ((rawRegs as any[]) || []).map((r: any) => {
    const student = Array.isArray(r.student_profiles)
      ? r.student_profiles[0]
      : r.student_profiles;

    return {
      id: r.id,
      status: r.status,
      registration_number: r.registration_number,
      created_at: r.created_at,
      student: {
        name: student?.name,
        roll_number: student?.roll_number,
        enrollment_number: student?.enrollment_number,
        phone: student?.phone,
      },
    };
  });

  // 4. Get answers if any registrations exist
  const answerMap: Record<string, Record<string, string>> = {};
  if (registrations.length > 0) {
    const regIds = registrations.map((r) => r.id);
    const { data: answersData } = await (supabase
      .from("registration_answers") as any)
      .select("registration_id, question_id, answer_value")
      .in("registration_id", regIds);

    for (const a of (answersData as any[]) || []) {
      if (!answerMap[a.registration_id]) {
        answerMap[a.registration_id] = {};
      }
      answerMap[a.registration_id][a.question_id] = a.answer_value || "";
    }
  }

  return (
    <EventResponsesClient
      eventId={event.id}
      eventTitle={event.title}
      questions={questions}
      registrations={registrations}
      answers={answerMap}
    />
  );
}

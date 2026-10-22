import React from "react";
import { createClient } from "@/lib/supabase/server";
import { notFound, redirect } from "next/navigation";
import { FormBuilderClient, QuestionDraft, FormSettings } from "./FormBuilderClient";

export async function generateMetadata({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data } = await (supabase.from("events") as any)
    .select("title")
    .eq("id", params.id)
    .maybeSingle();

  return {
    title: `Form Builder — ${data?.title || "Event"} — ZEST Admin`,
  };
}

export default async function FormBuilderPage({
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

  // 2. Get or create registration form
  let { data: form } = await (supabase.from("registration_forms") as any)
    .select("*")
    .eq("event_id", params.id)
    .maybeSingle();

  if (!form) {
    const { data: newForm } = await (supabase.from("registration_forms") as any)
      .insert({ event_id: params.id })
      .select("*")
      .single();
    form = newForm;
  }

  // 3. Get or create form section
  let { data: section } = await (supabase.from("form_sections") as any)
    .select("id")
    .eq("form_id", form.id)
    .order("order_index", { ascending: true })
    .maybeSingle();

  if (!section) {
    const { data: newSection } = await (supabase.from("form_sections") as any)
      .insert({
        form_id: form.id,
        title: "Registration Details",
        order_index: 0,
      })
      .select("id")
      .single();
    section = newSection;
  }

  // 4. Fetch questions and options
  const { data: rawQuestions } = await (supabase.from("form_questions") as any)
    .select(
      "id, title, description, question_type, is_required, character_limit, min_value, max_value, order_index, question_options(value, order_index)"
    )
    .eq("section_id", section.id)
    .order("order_index", { ascending: true });

  const initialQuestions: QuestionDraft[] = ((rawQuestions as any[]) || []).map(
    (q: any) => {
      const opts = (q.question_options || []).sort(
        (a: any, b: any) => (a.order_index ?? 0) - (b.order_index ?? 0)
      );
      return {
        id: q.id,
        title: q.title || "",
        description: q.description || "",
        question_type: q.question_type || "short_answer",
        is_required: !!q.is_required,
        character_limit: q.character_limit,
        min_value: q.min_value,
        max_value: q.max_value,
        order_index: q.order_index ?? 0,
        options: opts.map((o: any) => o.value),
      };
    }
  );

  const initialSettings: FormSettings = {
    auto_approval: !!form.auto_approval,
    allow_waitlist: !!form.allow_waitlist,
    one_response_only: form.one_response_only !== false,
    editable_response: !!form.editable_response,
    confirmation_message:
      form.confirmation_message || "Thank you for registering!",
    max_responses: form.max_responses,
    close_on_limit: !!form.close_on_limit,
    form_open_date: form.form_open_date,
    form_close_date: form.form_close_date,
  };

  return (
    <FormBuilderClient
      eventId={event.id}
      eventTitle={event.title}
      formId={form.id}
      sectionId={section.id}
      initialQuestions={initialQuestions}
      initialSettings={initialSettings}
    />
  );
}

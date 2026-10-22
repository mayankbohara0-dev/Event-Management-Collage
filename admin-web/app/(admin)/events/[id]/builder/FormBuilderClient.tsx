"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Plus,
  Trash2,
  Copy,
  Settings2,
  ListPlus,
  Save,
  FileText,
  AlignLeft,
  CheckSquare,
  Radio,
  ChevronDown,
  Star,
  Hash,
  Mail,
  Phone,
  Calendar,
  Clock,
  UploadCloud,
  GraduationCap,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Textarea } from "@/components/ui/Textarea";
import { Switch } from "@/components/ui/Switch";
import { Badge } from "@/components/ui/Badge";
import { createClient } from "@/lib/supabase/client";

export interface QuestionDraft {
  id: string;
  title: string;
  description?: string;
  question_type: string;
  is_required: boolean;
  character_limit?: number | null;
  min_value?: number | null;
  max_value?: number | null;
  order_index: number;
  options: string[];
}

export interface FormSettings {
  auto_approval: boolean;
  allow_waitlist: boolean;
  one_response_only: boolean;
  editable_response: boolean;
  confirmation_message: string;
  max_responses?: number | null;
  close_on_limit: boolean;
  form_open_date?: string | null;
  form_close_date?: string | null;
}

interface FormBuilderClientProps {
  eventId: string;
  eventTitle: string;
  formId: string;
  sectionId: string;
  initialQuestions: QuestionDraft[];
  initialSettings: FormSettings;
}

const QUESTION_TYPES = [
  { type: "short_answer", label: "Short Answer", icon: FileText, group: "Text" },
  { type: "paragraph", label: "Paragraph", icon: AlignLeft, group: "Text" },
  { type: "radio", label: "Multiple Choice", icon: Radio, group: "Choice" },
  { type: "checkbox", label: "Checkboxes", icon: CheckSquare, group: "Choice" },
  { type: "dropdown", label: "Dropdown", icon: ChevronDown, group: "Choice" },
  { type: "rating", label: "Rating (Stars)", icon: Star, group: "Scale" },
  { type: "linear_scale", label: "Linear Scale", icon: Hash, group: "Scale" },
  { type: "email", label: "Email", icon: Mail, group: "Contact" },
  { type: "phone", label: "Phone Number", icon: Phone, group: "Contact" },
  { type: "number", label: "Number", icon: Hash, group: "Contact" },
  { type: "date", label: "Date", icon: Calendar, group: "Time" },
  { type: "time", label: "Time", icon: Clock, group: "Time" },
  { type: "file_upload", label: "File Upload", icon: UploadCloud, group: "File" },
  { type: "roll_number", label: "Roll Number", icon: GraduationCap, group: "Campus" },
  { type: "department", label: "Department", icon: GraduationCap, group: "Campus" },
  { type: "semester", label: "Semester", icon: GraduationCap, group: "Campus" },
];

export function FormBuilderClient({
  eventId,
  eventTitle,
  formId,
  sectionId,
  initialQuestions,
  initialSettings,
}: FormBuilderClientProps) {
  const router = useRouter();
  const supabase = createClient();

  const [activeTab, setActiveTab] = useState<"questions" | "settings">("questions");
  const [questions, setQuestions] = useState<QuestionDraft[]>(initialQuestions);
  const [settings, setSettings] = useState<FormSettings>(initialSettings);
  const [isSaving, setIsSaving] = useState(false);
  const [selectedQId, setSelectedQId] = useState<string | null>(
    initialQuestions.length > 0 ? initialQuestions[0].id : null
  );

  const addQuestion = (type = "short_answer") => {
    const newQ: QuestionDraft = {
      id: `temp_${Date.now()}`,
      title: "Untitled Question",
      description: "",
      question_type: type,
      is_required: false,
      character_limit: null,
      min_value: type === "rating" ? 1 : type === "linear_scale" ? 1 : null,
      max_value: type === "rating" ? 5 : type === "linear_scale" ? 10 : null,
      order_index: questions.length,
      options: ["radio", "checkbox", "dropdown"].includes(type)
        ? ["Option 1", "Option 2"]
        : [],
    };
    setQuestions([...questions, newQ]);
    setSelectedQId(newQ.id);
  };

  const updateQuestion = (id: string, updates: Partial<QuestionDraft>) => {
    setQuestions(
      questions.map((q) => (q.id === id ? { ...q, ...updates } : q))
    );
  };

  const removeQuestion = (id: string) => {
    const updated = questions.filter((q) => q.id !== id);
    setQuestions(updated);
    if (selectedQId === id) {
      setSelectedQId(updated.length > 0 ? updated[0].id : null);
    }
  };

  const duplicateQuestion = (id: string) => {
    const target = questions.find((q) => q.id === id);
    if (!target) return;
    const duplicated: QuestionDraft = {
      ...target,
      id: `temp_${Date.now()}`,
      title: `${target.title} (Copy)`,
      order_index: questions.length,
      options: [...target.options],
    };
    setQuestions([...questions, duplicated]);
    setSelectedQId(duplicated.id);
  };

  const moveQuestion = (fromIdx: number, toIdx: number) => {
    if (toIdx < 0 || toIdx >= questions.length) return;
    const items = [...questions];
    const [moved] = items.splice(fromIdx, 1);
    items.splice(toIdx, 0, moved);
    const reindexed = items.map((item, idx) => ({ ...item, order_index: idx }));
    setQuestions(reindexed);
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      // 1. Update form settings
      const { error: formError } = await (supabase
        .from("registration_forms") as any)
        .update({
          auto_approval: settings.auto_approval,
          allow_waitlist: settings.allow_waitlist,
          one_response_only: settings.one_response_only,
          editable_response: settings.editable_response,
          confirmation_message: settings.confirmation_message,
          max_responses: settings.max_responses || null,
          close_on_limit: settings.close_on_limit,
          form_open_date: settings.form_open_date || null,
          form_close_date: settings.form_close_date || null,
        })
        .eq("id", formId);

      if (formError) throw formError;

      // 2. Fetch existing question IDs in DB to handle deletions
      const { data: existingQs } = await (supabase
        .from("form_questions") as any)
        .select("id")
        .eq("section_id", sectionId);

      const existingIds = new Set(
        ((existingQs as any[]) || []).map((q: any) => q.id)
      );
      const currentIds = new Set(
        questions.filter((q) => !q.id.startsWith("temp_")).map((q) => q.id)
      );

      // Delete questions removed by organizer
      for (const oldId of Array.from(existingIds)) {
        if (!currentIds.has(oldId)) {
          await (supabase.from("form_questions") as any)
            .delete()
            .eq("id", oldId);
        }
      }

      // Upsert questions
      for (let i = 0; i < questions.length; i++) {
        const q = questions[i];
        let questionId = q.id;

        if (q.id.startsWith("temp_")) {
          // Insert new
          const { data: created, error: createErr } = await (supabase
            .from("form_questions") as any)
            .insert({
              section_id: sectionId,
              title: q.title,
              description: q.description || null,
              question_type: q.question_type,
              is_required: q.is_required,
              character_limit: q.character_limit || null,
              min_value: q.min_value || null,
              max_value: q.max_value || null,
              order_index: i,
            })
            .select("id")
            .single();

          if (createErr) throw createErr;
          questionId = (created as any).id;
        } else {
          // Update existing
          const { error: updateErr } = await (supabase
            .from("form_questions") as any)
            .update({
              title: q.title,
              description: q.description || null,
              question_type: q.question_type,
              is_required: q.is_required,
              character_limit: q.character_limit || null,
              min_value: q.min_value || null,
              max_value: q.max_value || null,
              order_index: i,
            })
            .eq("id", questionId);

          if (updateErr) throw updateErr;

          // Delete old options to re-insert cleanly
          await (supabase.from("question_options") as any)
            .delete()
            .eq("question_id", questionId);
        }

        // Insert options if choice question
        if (
          ["radio", "checkbox", "dropdown"].includes(q.question_type) &&
          q.options.length > 0
        ) {
          const optPayload = q.options.map((optText, optIdx) => ({
            question_id: questionId,
            value: optText,
            order_index: optIdx,
          }));
          await (supabase.from("question_options") as any).insert(optPayload);
        }
      }

      toast.success("Registration form saved successfully!");
      router.refresh();
    } catch (err: any) {
      toast.error(err.message || "Failed to save form");
    } finally {
      setIsSaving(false);
    }
  };

  const selectedQuestion = questions.find((q) => q.id === selectedQId);
  const selectedIdx = questions.findIndex((q) => q.id === selectedQId);

  return (
    <div className="space-y-6 pb-20">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-line pb-4">
        <div className="flex items-center gap-3">
          <Link href={`/events/${eventId}`}>
            <button className="p-2 rounded-card hover:bg-fill transition-colors text-ink-3">
              <ArrowLeft size={18} />
            </button>
          </Link>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-ink tracking-tight">
                Form Builder
              </h1>
              <Badge variant="brand">Dynamic Fields</Badge>
            </div>
            <p className="text-xs text-ink-2 mt-0.5">
              Registration questions for:{" "}
              <span className="font-semibold text-ink">{eventTitle}</span>
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Tab Switcher */}
          <div className="flex bg-fill p-1 rounded-pill border border-line">
            <button
              onClick={() => setActiveTab("questions")}
              className={`px-3 py-1.5 rounded-pill text-xs font-semibold transition-all ${
                activeTab === "questions"
                  ? "bg-card text-ink shadow-sm"
                  : "text-ink-3 hover:text-ink"
              }`}
            >
              Questions ({questions.length})
            </button>
            <button
              onClick={() => setActiveTab("settings")}
              className={`px-3 py-1.5 rounded-pill text-xs font-semibold transition-all ${
                activeTab === "settings"
                  ? "bg-card text-ink shadow-sm"
                  : "text-ink-3 hover:text-ink"
              }`}
            >
              Form Settings
            </button>
          </div>

          <Button
            size="sm"
            onClick={handleSave}
            isLoading={isSaving}
            leftIcon={<Save size={15} />}
          >
            Save form
          </Button>
        </div>
      </div>

      {activeTab === "settings" ? (
        /* Settings Tab */
        <div className="max-w-2xl mx-auto space-y-6">
          <div className="bg-card rounded-card border border-line p-6 space-y-5">
            <h2 className="text-base font-bold text-ink tracking-tight flex items-center gap-2">
              <Settings2 size={18} className="text-brand-core" />
              Registration Rules & Responses
            </h2>

            <div className="flex items-center justify-between py-3 border-b border-line/60">
              <div>
                <p className="text-sm font-semibold text-ink">Auto-approve registrations</p>
                <p className="text-xs text-ink-3 mt-0.5">
                  Immediately approve attendees upon submission without manual review
                </p>
              </div>
              <Switch
                checked={settings.auto_approval}
                onCheckedChange={(checked: boolean) =>
                  setSettings({ ...settings, auto_approval: checked })
                }
              />
            </div>

            <div className="flex items-center justify-between py-3 border-b border-line/60">
              <div>
                <p className="text-sm font-semibold text-ink">Waitlist after capacity</p>
                <p className="text-xs text-ink-3 mt-0.5">
                  Place new submissions onto waitlist once seat limit is filled
                </p>
              </div>
              <Switch
                checked={settings.allow_waitlist}
                onCheckedChange={(checked: boolean) =>
                  setSettings({ ...settings, allow_waitlist: checked })
                }
              />
            </div>

            <div className="flex items-center justify-between py-3 border-b border-line/60">
              <div>
                <p className="text-sm font-semibold text-ink">One response per student</p>
                <p className="text-xs text-ink-3 mt-0.5">
                  Prevent multiple passes from being booked under the same student profile
                </p>
              </div>
              <Switch
                checked={settings.one_response_only}
                onCheckedChange={(checked: boolean) =>
                  setSettings({ ...settings, one_response_only: checked })
                }
              />
            </div>

            <div className="flex items-center justify-between py-3 border-b border-line/60">
              <div>
                <p className="text-sm font-semibold text-ink">Allow editing submission</p>
                <p className="text-xs text-ink-3 mt-0.5">
                  Permit students to update answers up until the registration close date
                </p>
              </div>
              <Switch
                checked={settings.editable_response}
                onCheckedChange={(checked: boolean) =>
                  setSettings({ ...settings, editable_response: checked })
                }
              />
            </div>

            <div className="pt-2">
              <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                Confirmation Message
              </label>
              <Textarea
                rows={3}
                value={settings.confirmation_message}
                onChange={(e) =>
                  setSettings({ ...settings, confirmation_message: e.target.value })
                }
                placeholder="Thank you for registering! Show your QR pass at the entrance."
              />
            </div>
          </div>
        </div>
      ) : (
        /* Questions Builder Tab */
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* Left Column: Question List */}
          <div className="lg:col-span-5 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-ink-3">
                Questions ({questions.length})
              </span>
              <div className="flex gap-1.5">
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={() => addQuestion("short_answer")}
                  leftIcon={<Plus size={14} />}
                >
                  Add question
                </Button>
              </div>
            </div>

            <div className="space-y-2">
              {questions.map((q, idx) => {
                const isSelected = q.id === selectedQId;
                const typeInfo =
                  QUESTION_TYPES.find((t) => t.type === q.question_type) ||
                  QUESTION_TYPES[0];
                const IconComponent = typeInfo.icon;

                return (
                  <div
                    key={q.id}
                    onClick={() => setSelectedQId(q.id)}
                    className={`p-3.5 rounded-card border transition-all cursor-pointer flex items-center justify-between gap-3 group ${
                      isSelected
                        ? "bg-card border-brand-core shadow-sm ring-2 ring-brand-core/10"
                        : "bg-card border-line hover:border-brand-core/40"
                    }`}
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="flex flex-col gap-0.5 text-ink-3">
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            moveQuestion(idx, idx - 1);
                          }}
                          disabled={idx === 0}
                          className="hover:text-ink disabled:opacity-20 text-[10px]"
                        >
                          ▲
                        </button>
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            moveQuestion(idx, idx + 1);
                          }}
                          disabled={idx === questions.length - 1}
                          className="hover:text-ink disabled:opacity-20 text-[10px]"
                        >
                          ▼
                        </button>
                      </div>

                      <div className="w-8 h-8 rounded-full bg-fill text-brand-core flex items-center justify-center shrink-0">
                        <IconComponent size={15} />
                      </div>

                      <div className="truncate">
                        <p className="text-sm font-semibold text-ink truncate">
                          {q.title || "Untitled Question"}
                        </p>
                        <p className="text-xs text-ink-3 flex items-center gap-1.5">
                          <span>{typeInfo.label}</span>
                          {q.is_required && (
                            <span className="text-semantic-danger font-medium">
                              • Required
                            </span>
                          )}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          duplicateQuestion(q.id);
                        }}
                        className="p-1 rounded text-ink-3 hover:text-ink hover:bg-fill"
                        title="Duplicate"
                      >
                        <Copy size={13} />
                      </button>
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          removeQuestion(q.id);
                        }}
                        className="p-1 rounded text-ink-3 hover:text-semantic-danger hover:bg-semantic-danger/10"
                        title="Delete"
                      >
                        <Trash2 size={13} />
                      </button>
                    </div>
                  </div>
                );
              })}

              {questions.length === 0 && (
                <div className="p-8 border border-dashed border-line rounded-card text-center bg-card">
                  <ListPlus size={32} className="mx-auto text-ink-3 mb-2" />
                  <p className="text-sm font-semibold text-ink">No questions added</p>
                  <p className="text-xs text-ink-3 mt-1 mb-4">
                    Add custom fields to collect info like t-shirt size or team members.
                  </p>
                  <Button size="sm" onClick={() => addQuestion("short_answer")}>
                    Add first question
                  </Button>
                </div>
              )}
            </div>
          </div>

          {/* Right Column: Question Editor */}
          <div className="lg:col-span-7">
            {selectedQuestion ? (
              <div className="bg-card rounded-card border border-line p-6 space-y-6 shadow-sm">
                <div className="flex items-center justify-between border-b border-line pb-4">
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-mono text-ink-3 bg-fill px-2 py-0.5 rounded">
                      Q{(selectedIdx ?? 0) + 1}
                    </span>
                    <span className="text-sm font-semibold text-ink">
                      Edit Question
                    </span>
                  </div>

                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2">
                      <label className="text-xs font-medium text-ink-2">
                        Required
                      </label>
                      <Switch
                        checked={selectedQuestion.is_required}
                        onCheckedChange={(checked: boolean) =>
                          updateQuestion(selectedQuestion.id, {
                            is_required: checked,
                          })
                        }
                      />
                    </div>
                    <button
                      type="button"
                      onClick={() => removeQuestion(selectedQuestion.id)}
                      className="p-1.5 rounded-card text-semantic-danger hover:bg-semantic-danger/10 transition-colors"
                      title="Delete question"
                    >
                      <Trash2 size={15} />
                    </button>
                  </div>
                </div>

                {/* Question Title & Type */}
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div className="sm:col-span-2">
                    <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                      Question Prompt
                    </label>
                    <Input
                      value={selectedQuestion.title}
                      onChange={(e) =>
                        updateQuestion(selectedQuestion.id, {
                          title: e.target.value,
                        })
                      }
                      placeholder="e.g. Dietary requirements or GitHub profile"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                      Response Type
                    </label>
                    <select
                      value={selectedQuestion.question_type}
                      onChange={(e) => {
                        const newType = e.target.value;
                        const defaultOpts = ["radio", "checkbox", "dropdown"].includes(
                          newType
                        )
                          ? selectedQuestion.options.length > 0
                            ? selectedQuestion.options
                            : ["Option 1", "Option 2"]
                          : [];
                        updateQuestion(selectedQuestion.id, {
                          question_type: newType,
                          options: defaultOpts,
                        });
                      }}
                      className="w-full h-10 px-3 rounded-card bg-fill border border-line text-xs font-medium text-ink focus:outline-none focus:ring-2 focus:ring-brand-core/20"
                    >
                      {QUESTION_TYPES.map((t) => (
                        <option key={t.type} value={t.type}>
                          {t.label} ({t.group})
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Question Description */}
                <div>
                  <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                    Help Text / Description (Optional)
                  </label>
                  <Input
                    value={selectedQuestion.description || ""}
                    onChange={(e) =>
                      updateQuestion(selectedQuestion.id, {
                        description: e.target.value,
                      })
                    }
                    placeholder="Instructions for attendee filling this out"
                  />
                </div>

                {/* Choice Options Editor */}
                {["radio", "checkbox", "dropdown"].includes(
                  selectedQuestion.question_type
                ) && (
                  <div className="space-y-3 pt-2 border-t border-line/60">
                    <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider">
                      Choice Options
                    </label>
                    <div className="space-y-2">
                      {selectedQuestion.options.map((opt, optIdx) => (
                        <div key={optIdx} className="flex items-center gap-2">
                          <span className="w-5 text-center text-xs text-ink-3">
                            {optIdx + 1}.
                          </span>
                          <Input
                            value={opt}
                            onChange={(e) => {
                              const newOpts = [...selectedQuestion.options];
                              newOpts[optIdx] = e.target.value;
                              updateQuestion(selectedQuestion.id, {
                                options: newOpts,
                              });
                            }}
                            placeholder={`Option ${optIdx + 1}`}
                          />
                          <button
                            type="button"
                            onClick={() => {
                              const newOpts = selectedQuestion.options.filter(
                                (_, idx) => idx !== optIdx
                              );
                              updateQuestion(selectedQuestion.id, {
                                options: newOpts,
                              });
                            }}
                            disabled={selectedQuestion.options.length <= 1}
                            className="p-2 text-ink-3 hover:text-semantic-danger disabled:opacity-20"
                          >
                            <Trash2 size={14} />
                          </button>
                        </div>
                      ))}
                    </div>
                    <Button
                      size="sm"
                      variant="secondary"
                      onClick={() =>
                        updateQuestion(selectedQuestion.id, {
                          options: [
                            ...selectedQuestion.options,
                            `Option ${selectedQuestion.options.length + 1}`,
                          ],
                        })
                      }
                      leftIcon={<Plus size={14} />}
                    >
                      Add option
                    </Button>
                  </div>
                )}

                {/* Star / Scale Config */}
                {(selectedQuestion.question_type === "rating" ||
                  selectedQuestion.question_type === "linear_scale") && (
                  <div className="grid grid-cols-2 gap-4 pt-2 border-t border-line/60">
                    <div>
                      <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                        Min Scale Value
                      </label>
                      <Input
                        type="number"
                        value={selectedQuestion.min_value || 1}
                        onChange={(e) =>
                          updateQuestion(selectedQuestion.id, {
                            min_value: parseInt(e.target.value) || 1,
                          })
                        }
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                        Max Scale Value
                      </label>
                      <Input
                        type="number"
                        value={selectedQuestion.max_value || 5}
                        onChange={(e) =>
                          updateQuestion(selectedQuestion.id, {
                            max_value: parseInt(e.target.value) || 5,
                          })
                        }
                      />
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <div className="p-12 border border-line rounded-card text-center bg-card text-ink-3">
                Select a question on the left to edit its properties or click "Add question".
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

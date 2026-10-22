"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import {
  ArrowLeft,
  Calendar,
  MapPin,
  Users,
  Globe,
  Mail,
  Phone,
  Tag,
  Info,
  Save,
  Eye,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Textarea } from "@/components/ui/Textarea";
import { Select } from "@/components/ui/Select";
import { Switch } from "@/components/ui/Switch";
import { createClient } from "@/lib/supabase/client";

interface EventFormClientProps {
  mode: "create" | "edit";
  event: any | null;
  categories: { id: string; name: string }[];
  departments: { id: string; name: string; code: string }[];
  adminId: string;
}

function Section({
  title,
  icon,
  children,
}: {
  title: string;
  icon: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="bg-card rounded-card border border-line p-6 space-y-4">
      <div className="flex items-center gap-2 pb-2 border-b border-line">
        <span className="text-brand-core">{icon}</span>
        <h2 className="text-sm font-semibold text-ink">{title}</h2>
      </div>
      {children}
    </div>
  );
}

function FormField({
  label,
  required,
  hint,
  children,
}: {
  label: string;
  required?: boolean;
  hint?: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
        {label}
        {required && <span className="text-semantic-danger ml-0.5">*</span>}
      </label>
      {children}
      {hint && <p className="text-xs text-ink-3 mt-1">{hint}</p>}
    </div>
  );
}

export function EventFormClient({
  mode,
  event,
  categories,
  departments,
  adminId,
}: EventFormClientProps) {
  const supabase = createClient();
  const router = useRouter();

  const toLocalDateTime = (iso: string | null) => {
    if (!iso) return "";
    return iso.slice(0, 16); // "YYYY-MM-DDTHH:mm"
  };

  const [form, setForm] = useState({
    title: event?.title || "",
    short_description: event?.short_description || "",
    long_description: event?.long_description || "",
    start_date: toLocalDateTime(event?.start_date),
    end_date: toLocalDateTime(event?.end_date),
    registration_start: toLocalDateTime(event?.registration_start),
    registration_end: toLocalDateTime(event?.registration_end),
    venue: event?.venue || "",
    building: event?.building || "",
    room: event?.room || "",
    google_maps_link: event?.google_maps_link || "",
    max_seats: event?.max_seats ? String(event.max_seats) : "",
    max_capacity: event?.max_capacity ? String(event.max_capacity) : "",
    eligibility: event?.eligibility || "",
    rules: event?.rules || "",
    requirements: event?.requirements || "",
    prize_details: event?.prize_details || "",
    agenda: event?.agenda || "",
    coordinator: event?.coordinator || "",
    faculty_in_charge: event?.faculty_in_charge || "",
    contact_number: event?.contact_number || "",
    email: event?.email || "",
    website: event?.website || "",
    dress_code: event?.dress_code || "",
    documents_required: event?.documents_required || "",
    sponsors: event?.sponsors || "",
    category_id: event?.category_id || "",
    department_id: event?.department_id || "",
    visibility: event?.visibility || "draft",
    tags: (event?.tags || []).join(", "),
  });

  const [saving, setSaving] = useState(false);

  const update = (key: string, val: string) => {
    setForm((f) => ({ ...f, [key]: val }));
  };

  const handleSave = async (publishAfter = false) => {
    if (!form.title.trim()) {
      toast.error("Event title is required.");
      return;
    }
    if (!form.short_description.trim()) {
      toast.error("Short description is required.");
      return;
    }
    if (!form.start_date || !form.end_date) {
      toast.error("Start and end date/time are required.");
      return;
    }
    if (new Date(form.start_date) >= new Date(form.end_date)) {
      toast.error("End date must be after start date.");
      return;
    }

    setSaving(true);

    const payload: any = {
      title: form.title.trim(),
      short_description: form.short_description.trim(),
      long_description: form.long_description.trim() || null,
      start_date: new Date(form.start_date).toISOString(),
      end_date: new Date(form.end_date).toISOString(),
      registration_start: form.registration_start
        ? new Date(form.registration_start).toISOString()
        : null,
      registration_end: form.registration_end
        ? new Date(form.registration_end).toISOString()
        : null,
      venue: form.venue.trim() || null,
      building: form.building.trim() || null,
      room: form.room.trim() || null,
      google_maps_link: form.google_maps_link.trim() || null,
      max_seats: form.max_seats ? parseInt(form.max_seats) : null,
      max_capacity: form.max_capacity ? parseInt(form.max_capacity) : null,
      eligibility: form.eligibility.trim() || null,
      rules: form.rules.trim() || null,
      requirements: form.requirements.trim() || null,
      prize_details: form.prize_details.trim() || null,
      agenda: form.agenda.trim() || null,
      coordinator: form.coordinator.trim() || null,
      faculty_in_charge: form.faculty_in_charge.trim() || null,
      contact_number: form.contact_number.trim() || null,
      email: form.email.trim() || null,
      website: form.website.trim() || null,
      dress_code: form.dress_code.trim() || null,
      documents_required: form.documents_required.trim() || null,
      sponsors: form.sponsors.trim() || null,
      category_id: form.category_id || null,
      department_id: form.department_id || null,
      visibility: publishAfter ? "published" : form.visibility,
      tags: form.tags
        ? form.tags
            .split(",")
            .map((t: string) => t.trim())
            .filter(Boolean)
        : [],
    };

    let result;
    if (mode === "create") {
      (payload as any).created_by = adminId;
      result = await (supabase.from("events") as any).insert(payload).select("id").single();
    } else {
      result = await (supabase
        .from("events") as any)
        .update(payload)
        .eq("id", event?.id)
        .select("id")
        .single();
    }

    setSaving(false);

    if (result.error) {
      toast.error("Failed to save event: " + result.error.message);
      return;
    }

    toast.success(
      mode === "create"
        ? "Event created successfully!"
        : "Event updated."
    );
    router.push(`/events/${result.data?.id}`);
  };

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link href={mode === "edit" ? `/events/${event?.id}` : "/events"}>
            <button className="p-1.5 rounded-card hover:bg-fill transition-colors text-ink-3">
              <ArrowLeft size={18} />
            </button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-ink tracking-tight">
              {mode === "create" ? (
                <>
                  Create{" "}
                  <span className="serif-accent font-normal text-brand-blue">
                    event
                  </span>
                </>
              ) : (
                <>
                  Edit{" "}
                  <span className="serif-accent font-normal text-brand-blue">
                    {event?.title}
                  </span>
                </>
              )}
            </h1>
            <p className="text-sm text-ink-2 mt-0.5">
              Fill in the details below. All fields marked * are required.
            </p>
          </div>
        </div>

        <div className="flex gap-2 shrink-0">
          <Button
            variant="outline"
            isLoading={saving}
            onClick={() => handleSave(false)}
            leftIcon={<Save size={15} />}
          >
            Save as{" "}
            {form.visibility === "published" ? "published" : "draft"}
          </Button>
          {form.visibility !== "published" && (
            <Button
              isLoading={saving}
              onClick={() => handleSave(true)}
              leftIcon={<Eye size={15} />}
            >
              Save &amp; Publish
            </Button>
          )}
        </div>
      </div>

      {/* Basic Info */}
      <Section title="Basic Information" icon={<Info size={16} />}>
        <FormField label="Event Title" required>
          <Input
            value={form.title}
            onChange={(e) => update("title", e.target.value)}
            placeholder="e.g., Annual Tech Fest 2025"
          />
        </FormField>
        <FormField
          label="Short Description"
          required
          hint="This appears on event cards and lists. Keep it concise (max 200 chars)."
        >
          <Textarea
            value={form.short_description}
            onChange={(e) => update("short_description", e.target.value)}
            placeholder="One-liner about the event…"
            rows={2}
            maxLength={200}
          />
        </FormField>
        <FormField label="Full Description">
          <Textarea
            value={form.long_description}
            onChange={(e) => update("long_description", e.target.value)}
            placeholder="Detailed description, what attendees can expect…"
            rows={5}
          />
        </FormField>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <FormField label="Category">
            <Select
              value={form.category_id}
              onChange={(e) => update("category_id", e.target.value)}
            >
              <option value="">No category</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </Select>
          </FormField>
          <FormField label="Department">
            <Select
              value={form.department_id}
              onChange={(e) => update("department_id", e.target.value)}
            >
              <option value="">All departments</option>
              {departments.map((d) => (
                <option key={d.id} value={d.id}>
                  {d.code} — {d.name}
                </option>
              ))}
            </Select>
          </FormField>
        </div>
        <FormField
          label="Tags"
          hint="Comma-separated. e.g., workshop, coding, prize"
        >
          <Input
            value={form.tags}
            onChange={(e) => update("tags", e.target.value)}
            placeholder="workshop, hackathon, open-to-all"
            leftIcon={<Tag size={15} />}
          />
        </FormField>
        <FormField label="Visibility">
          <Select
            value={form.visibility}
            onChange={(e) => update("visibility", e.target.value)}
          >
            <option value="draft">Draft (not visible to students)</option>
            <option value="published">Published (visible to students)</option>
            <option value="archived">Archived</option>
          </Select>
        </FormField>
      </Section>

      {/* Date & Time */}
      <Section title="Date & Time" icon={<Calendar size={16} />}>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <FormField label="Start Date & Time" required>
            <Input
              type="datetime-local"
              value={form.start_date}
              onChange={(e) => update("start_date", e.target.value)}
            />
          </FormField>
          <FormField label="End Date & Time" required>
            <Input
              type="datetime-local"
              value={form.end_date}
              onChange={(e) => update("end_date", e.target.value)}
            />
          </FormField>
          <FormField label="Registration Opens">
            <Input
              type="datetime-local"
              value={form.registration_start}
              onChange={(e) => update("registration_start", e.target.value)}
            />
          </FormField>
          <FormField label="Registration Closes">
            <Input
              type="datetime-local"
              value={form.registration_end}
              onChange={(e) => update("registration_end", e.target.value)}
            />
          </FormField>
        </div>
      </Section>

      {/* Venue */}
      <Section title="Venue & Location" icon={<MapPin size={16} />}>
        <FormField label="Venue Name">
          <Input
            value={form.venue}
            onChange={(e) => update("venue", e.target.value)}
            placeholder="e.g., Main Auditorium, Central Campus"
          />
        </FormField>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <FormField label="Building">
            <Input
              value={form.building}
              onChange={(e) => update("building", e.target.value)}
              placeholder="Building name or number"
            />
          </FormField>
          <FormField label="Room">
            <Input
              value={form.room}
              onChange={(e) => update("room", e.target.value)}
              placeholder="Room number"
            />
          </FormField>
        </div>
        <FormField label="Google Maps Link">
          <Input
            value={form.google_maps_link}
            onChange={(e) => update("google_maps_link", e.target.value)}
            placeholder="https://maps.google.com/…"
            leftIcon={<Globe size={15} />}
          />
        </FormField>
      </Section>

      {/* Capacity */}
      <Section title="Capacity & Eligibility" icon={<Users size={16} />}>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <FormField label="Max Seats" hint="Leave blank for unlimited">
            <Input
              type="number"
              min="1"
              value={form.max_seats}
              onChange={(e) => update("max_seats", e.target.value)}
              placeholder="e.g., 200"
            />
          </FormField>
          <FormField label="Max Capacity" hint="Physical room capacity">
            <Input
              type="number"
              min="1"
              value={form.max_capacity}
              onChange={(e) => update("max_capacity", e.target.value)}
              placeholder="e.g., 250"
            />
          </FormField>
        </div>
        <FormField label="Eligibility Criteria">
          <Textarea
            value={form.eligibility}
            onChange={(e) => update("eligibility", e.target.value)}
            placeholder="Who can register? e.g., Open to all engineering students, Year 2–4."
            rows={3}
          />
        </FormField>
        <FormField label="Rules">
          <Textarea
            value={form.rules}
            onChange={(e) => update("rules", e.target.value)}
            placeholder="Event rules and regulations…"
            rows={3}
          />
        </FormField>
        <FormField label="Requirements" hint="What participants should bring">
          <Textarea
            value={form.requirements}
            onChange={(e) => update("requirements", e.target.value)}
            placeholder="Laptop, ID card, etc."
            rows={2}
          />
        </FormField>
        <FormField label="Dress Code">
          <Input
            value={form.dress_code}
            onChange={(e) => update("dress_code", e.target.value)}
            placeholder="Formal / Semi-formal / Casual"
          />
        </FormField>
        <FormField label="Documents Required">
          <Input
            value={form.documents_required}
            onChange={(e) => update("documents_required", e.target.value)}
            placeholder="College ID, Permission letter, etc."
          />
        </FormField>
      </Section>

      {/* Event Details */}
      <Section title="Event Details" icon={<Info size={16} />}>
        <FormField label="Agenda">
          <Textarea
            value={form.agenda}
            onChange={(e) => update("agenda", e.target.value)}
            placeholder="Schedule / agenda of the event…"
            rows={4}
          />
        </FormField>
        <FormField label="Prize Details">
          <Textarea
            value={form.prize_details}
            onChange={(e) => update("prize_details", e.target.value)}
            placeholder="Prize money, certificates, trophies…"
            rows={2}
          />
        </FormField>
        <FormField label="Sponsors">
          <Input
            value={form.sponsors}
            onChange={(e) => update("sponsors", e.target.value)}
            placeholder="Sponsor names / details"
          />
        </FormField>
      </Section>

      {/* Contact */}
      <Section title="Contact Information" icon={<Phone size={16} />}>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <FormField label="Event Coordinator">
            <Input
              value={form.coordinator}
              onChange={(e) => update("coordinator", e.target.value)}
              placeholder="Name of student coordinator"
              leftIcon={<Users size={15} />}
            />
          </FormField>
          <FormField label="Faculty In Charge">
            <Input
              value={form.faculty_in_charge}
              onChange={(e) => update("faculty_in_charge", e.target.value)}
              placeholder="Faculty supervisor"
              leftIcon={<Users size={15} />}
            />
          </FormField>
          <FormField label="Contact Number">
            <Input
              value={form.contact_number}
              onChange={(e) => update("contact_number", e.target.value)}
              placeholder="+91 98765 43210"
              leftIcon={<Phone size={15} />}
            />
          </FormField>
          <FormField label="Contact Email">
            <Input
              type="email"
              value={form.email}
              onChange={(e) => update("email", e.target.value)}
              placeholder="events@college.edu"
              leftIcon={<Mail size={15} />}
            />
          </FormField>
          <FormField label="Website">
            <Input
              value={form.website}
              onChange={(e) => update("website", e.target.value)}
              placeholder="https://event.example.com"
              leftIcon={<Globe size={15} />}
            />
          </FormField>
        </div>
      </Section>

      {/* Sticky Bottom Bar */}
      <div className="sticky bottom-0 z-30 bg-card/90 backdrop-blur border-t border-line px-6 py-4 -mx-4 sm:-mx-6 lg:-mx-8 flex items-center justify-end gap-3">
        <Link href={mode === "edit" ? `/events/${event?.id}` : "/events"}>
          <Button variant="ghost">Discard</Button>
        </Link>
        <Button
          variant="outline"
          isLoading={saving}
          onClick={() => handleSave(false)}
          leftIcon={<Save size={15} />}
        >
          Save Draft
        </Button>
        {form.visibility !== "published" && (
          <Button
            isLoading={saving}
            onClick={() => handleSave(true)}
            leftIcon={<Eye size={15} />}
          >
            Publish
          </Button>
        )}
        {form.visibility === "published" && (
          <Button
            isLoading={saving}
            onClick={() => handleSave(false)}
            leftIcon={<Save size={15} />}
          >
            Save Changes
          </Button>
        )}
      </div>
    </div>
  );
}

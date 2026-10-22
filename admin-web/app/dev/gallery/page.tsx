"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  ArrowLeft,
  Calendar,
  Search,
  CheckCircle2,
  AlertTriangle,
  Download,
  Trash2,
  Mail,
  Lock,
  Plus,
  Flame,
  Star,
  Users,
} from "lucide-react";
import { ColumnDef } from "@tanstack/react-table";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { Mascot, MascotMood, MascotTint } from "@/components/brand/Mascot";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Textarea } from "@/components/ui/Textarea";
import { Select } from "@/components/ui/Select";
import { Switch } from "@/components/ui/Switch";
import { Checkbox } from "@/components/ui/Checkbox";
import { SegmentedToggle } from "@/components/ui/SegmentedToggle";
import { Badge, StatusPill } from "@/components/ui/Badge";
import { Card, SectionCard } from "@/components/ui/Card";
import { StatCard } from "@/components/ui/StatCard";
import { Drawer } from "@/components/ui/Drawer";
import { Dialog, ConfirmDialog } from "@/components/ui/Dialog";
import { EmptyState } from "@/components/ui/EmptyState";
import { Skeleton } from "@/components/ui/Skeleton";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Stepper } from "@/components/ui/Stepper";
import { Kbd } from "@/components/ui/Kbd";
import { Tooltip } from "@/components/ui/Tooltip";
import { DataTable } from "@/components/ui/DataTable";
import { toast } from "sonner";

interface SampleRegistration {
  id: string;
  name: string;
  roll: string;
  department: string;
  status: "approved" | "pending" | "rejected" | "attended";
  registeredAt: string;
}

const SAMPLE_DATA: SampleRegistration[] = [
  {
    id: "reg-1",
    name: "Aarav Sharma",
    roll: "21CS042",
    department: "Computer Science",
    status: "approved",
    registeredAt: "Oct 22, 10:30 AM",
  },
  {
    id: "reg-2",
    name: "Priya Patel",
    roll: "22EC018",
    department: "Electronics",
    status: "attended",
    registeredAt: "Oct 22, 11:15 AM",
  },
  {
    id: "reg-3",
    name: "Rohan Deshmukh",
    roll: "21ME095",
    department: "Mechanical",
    status: "pending",
    registeredAt: "Oct 22, 01:45 PM",
  },
  {
    id: "reg-4",
    name: "Ananya Iyer",
    roll: "23IT004",
    department: "Information Tech",
    status: "rejected",
    registeredAt: "Oct 22, 02:00 PM",
  },
];

export default function DevGalleryPage() {
  // State for interactive gallery demos
  const [switchVal, setSwitchVal] = useState(true);
  const [checkboxVal, setCheckboxVal] = useState(true);
  const [segmentedVal, setSegmentedVal] = useState<string>("table");
  const [dateRangeVal, setDateRangeVal] = useState<string>("30d");
  const [stepperVal, setStepperVal] = useState(150);
  const [progressVal, setProgressVal] = useState(68);

  const [mascotMood, setMascotMood] = useState<MascotMood>("happy");
  const [mascotTint, setMascotTint] = useState<MascotTint>("blue");

  const [drawerOpen, setDrawerOpen] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);

  // Table columns definition for DataTable demo
  const sampleColumns: ColumnDef<SampleRegistration>[] = [
    {
      id: "select",
      header: ({ table }) => (
        <Checkbox
          checked={table.getIsAllPageRowsSelected()}
          onCheckedChange={(val) => table.toggleAllPageRowsSelected(val)}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(val) => row.toggleSelected(val)}
        />
      ),
    },
    {
      accessorKey: "name",
      header: "Student Name",
      cell: ({ row }) => (
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-full bg-brand-tint text-brand-blue font-bold text-xs flex items-center justify-center shrink-0">
            {row.original.name[0]}
          </div>
          <div>
            <span className="font-semibold text-ink block">{row.original.name}</span>
            <span className="text-[11px] text-ink-3">{row.original.roll}</span>
          </div>
        </div>
      ),
    },
    {
      accessorKey: "department",
      header: "Department",
      cell: ({ row }) => <span className="text-xs text-ink-2">{row.original.department}</span>,
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => <StatusPill status={row.original.status} size="sm" />,
    },
    {
      accessorKey: "registeredAt",
      header: "Registered",
      cell: ({ row }) => (
        <span className="text-xs text-ink-3 tabular-nums">{row.original.registeredAt}</span>
      ),
    },
  ];

  return (
    <div className="min-h-screen bg-page text-ink p-6 lg:p-12 max-w-6xl mx-auto space-y-12">
      {/* Gallery Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-line">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-brand-core uppercase tracking-wider mb-1">
            <span className="w-2 h-2 rounded-full bg-brand-core animate-pulse" />
            ZEST Design System & Component Gallery
          </div>
          <h1 className="text-3xl lg:text-4xl font-bold tracking-tight text-ink">
            Design <span className="serif-accent font-normal text-brand-blue">Tokens</span> & Primitives
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            Off-white canvas, white cards, big clean type with Instrument Serif italic accent word, soft gradients.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Link href="/dashboard">
            <Button variant="outline" leftIcon={<ArrowLeft size={16} />}>
              Open Dashboard
            </Button>
          </Link>
          <Button
            onClick={() => toast.success("Toast notifications are fully wired! 🍋⚡")}
            leftIcon={<Flame size={16} />}
          >
            Trigger Toast
          </Button>
        </div>
      </div>

      {/* ── 1. Brand & Mascots ────────────────────────────────────────────── */}
      <section className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-bold tracking-tight text-ink">
            1. Brand & Mascot <span className="serif-accent font-normal text-brand-blue">Moments</span>
          </h2>
          <span className="text-xs text-ink-3">Blinks every 3–5s • Micro-bobbing breathing curve</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="flex flex-col items-center text-center p-6 space-y-3">
            <BlobLogo size={72} />
            <div>
              <span className="font-semibold text-sm block">&lt;BlobLogo /&gt;</span>
              <span className="text-xs text-ink-3">Squircle rx38, brand gradient, lemon</span>
            </div>
          </Card>

          <Card className="flex flex-col items-center text-center p-6 space-y-3">
            <Mascot size={72} mood="idle" tint="blue" />
            <div>
              <span className="font-semibold text-sm block">Mascot: Idle</span>
              <span className="text-xs text-ink-3">Automatic eye blinks</span>
            </div>
          </Card>

          <Card className="flex flex-col items-center text-center p-6 space-y-3">
            <Mascot size={72} mood="happy" tint="lemon" />
            <div>
              <span className="font-semibold text-sm block">Mascot: Happy</span>
              <span className="text-xs text-ink-3">Squint smile arcs • Lemon tint</span>
            </div>
          </Card>

          <Card className="flex flex-col items-center text-center p-6 space-y-3">
            <Mascot size={72} mood="celebrate" tint="coral" />
            <div>
              <span className="font-semibold text-sm block">Mascot: Celebrate</span>
              <span className="text-xs text-ink-3">Floating stars & bounce • Coral tint</span>
            </div>
          </Card>
        </div>

        {/* Mascot Interactive Studio */}
        <Card className="p-6 bg-brand-tint/30 border border-brand-core/20">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-4">
              <Mascot size={80} mood={mascotMood} tint={mascotTint} />
              <div>
                <h4 className="font-bold text-base text-ink">Interactive Mascot Sandbox</h4>
                <p className="text-xs text-ink-2">Tap options below to change emotion and color tint live.</p>
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <div className="space-y-1">
                <span className="text-[10px] font-bold text-ink-3 uppercase block">Mood</span>
                <div className="flex gap-1 bg-card p-1 rounded-pill border border-line">
                  {(["idle", "happy", "sleepy", "celebrate"] as MascotMood[]).map((m) => (
                    <button
                      key={m}
                      type="button"
                      onClick={() => setMascotMood(m)}
                      className={`text-xs px-2.5 py-1 rounded-pill capitalize transition-all ${
                        mascotMood === m ? "bg-brand-core text-white font-semibold shadow-sm" : "text-ink-2 hover:text-ink"
                      }`}
                    >
                      {m}
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-1">
                <span className="text-[10px] font-bold text-ink-3 uppercase block">Tint</span>
                <div className="flex gap-1.5 bg-card p-1.5 rounded-pill border border-line">
                  {(["blue", "lemon", "coral", "lavender", "mint", "aqua"] as MascotTint[]).map((t) => (
                    <button
                      key={t}
                      type="button"
                      onClick={() => setMascotTint(t)}
                      className={`w-5 h-5 rounded-full transition-transform ${
                        mascotTint === t ? "scale-125 ring-2 ring-brand-core ring-offset-1" : "hover:scale-110"
                      }`}
                      style={{
                        backgroundColor:
                          t === "blue" ? "#0AA5F0" :
                          t === "lemon" ? "#FFD84D" :
                          t === "coral" ? "#FF6B8A" :
                          t === "lavender" ? "#8E8BEA" :
                          t === "mint" ? "#3DDC97" : "#6CE3FF",
                      }}
                      title={t}
                    />
                  ))}
                </div>
              </div>
            </div>
          </div>
        </Card>
      </section>

      {/* ── 2. Buttons & Actions ─────────────────────────────────────────── */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          2. Buttons & Press <span className="serif-accent font-normal text-brand-blue">Micro-interactions</span>
        </h2>

        <Card className="p-6 space-y-6">
          <div>
            <h4 className="text-xs font-semibold text-ink-3 uppercase tracking-wider mb-3">Variants</h4>
            <div className="flex flex-wrap items-center gap-3">
              <Button variant="primary">Primary Gradient Pill</Button>
              <Button variant="secondary">Secondary Fill</Button>
              <Button variant="outline">Outline Hairline</Button>
              <Button variant="ghost">Ghost Plain</Button>
              <Button variant="danger">Danger Red</Button>
              <Button variant="primary" isLoading>Loading State</Button>
            </div>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-ink-3 uppercase tracking-wider mb-3">Sizes & Icon Slots</h4>
            <div className="flex flex-wrap items-center gap-3">
              <Button size="sm" leftIcon={<Plus size={14} />}>Small Button</Button>
              <Button size="md" leftIcon={<Users size={16} />}>Medium Button</Button>
              <Button size="lg" rightIcon={<Download size={18} />}>Large Button</Button>
              <Button size="icon" variant="secondary" title="Icon Only">
                <Star size={16} />
              </Button>
            </div>
          </div>
        </Card>
      </section>

      {/* ── 3. Form Controls & Inputs ────────────────────────────────────── */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          3. Form Controls & <span className="serif-accent font-normal text-brand-blue">Inputs</span>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Card className="p-6 space-y-4">
            <h4 className="text-sm font-bold text-ink">Text Inputs & Selects (radius 14px)</h4>
            <div>
              <label className="text-xs font-semibold text-ink-2 uppercase block mb-1">Standard Input</label>
              <Input placeholder="Enter event title..." />
            </div>

            <div>
              <label className="text-xs font-semibold text-ink-2 uppercase block mb-1">With Left Icon & Helper</label>
              <Input
                placeholder="coordinator@university.edu"
                leftIcon={<Mail size={16} />}
                helperText="Pre-filled from organizer profile"
              />
            </div>

            <div>
              <label className="text-xs font-semibold text-ink-2 uppercase block mb-1">Error State</label>
              <Input
                defaultValue="invalid_email"
                leftIcon={<Mail size={16} />}
                error="Please enter a valid university email address"
              />
            </div>

            <div>
              <label className="text-xs font-semibold text-ink-2 uppercase block mb-1">Department Select</label>
              <Select defaultValue="cs">
                <option value="cs">Computer Science & Engineering</option>
                <option value="ec">Electronics & Communication</option>
                <option value="me">Mechanical Engineering</option>
                <option value="all">Campus-wide (All Departments)</option>
              </Select>
            </div>
          </Card>

          <Card className="p-6 space-y-4">
            <h4 className="text-sm font-bold text-ink">Toggles, Checkboxes & Steppers</h4>
            <div className="space-y-3 pt-1">
              <Switch
                checked={switchVal}
                onCheckedChange={setSwitchVal}
                label="Auto-approval enabled"
                description="Immediately mark valid student registrations as Approved"
              />

              <div className="pt-2">
                <Checkbox
                  checked={checkboxVal}
                  onCheckedChange={setCheckboxVal}
                  label={<span>Require roll number verification before submission</span>}
                />
              </div>

              <div className="pt-3">
                <Stepper
                  value={stepperVal}
                  onChange={setStepperVal}
                  label="Seat Capacity Limit"
                  presets={[50, 100, 250, 500]}
                />
              </div>

              <div className="pt-2">
                <label className="text-xs font-semibold text-ink-2 uppercase block mb-1.5">
                  Live Seat Fill Rate ({progressVal}%)
                </label>
                <ProgressBar value={progressVal} max={100} showLabel size="md" />
                <div className="flex gap-2 mt-2">
                  <button
                    onClick={() => setProgressVal(45)}
                    className="text-[11px] px-2 py-0.5 bg-fill rounded hover:bg-line"
                  >
                    45% (Safe)
                  </button>
                  <button
                    onClick={() => setProgressVal(88)}
                    className="text-[11px] px-2 py-0.5 bg-fill rounded hover:bg-line"
                  >
                    88% (Warning)
                  </button>
                  <button
                    onClick={() => setProgressVal(98)}
                    className="text-[11px] px-2 py-0.5 bg-fill rounded hover:bg-line"
                  >
                    98% (Critical)
                  </button>
                </div>
              </div>
            </div>
          </Card>
        </div>
      </section>

      {/* ── 4. Segmented Toggles & Status Pills ───────────────────────────── */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          4. Segmented Controls & <span className="serif-accent font-normal text-brand-blue">Status Badges</span>
        </h2>

        <Card className="p-6 space-y-6">
          <div>
            <h4 className="text-xs font-semibold text-ink-3 uppercase tracking-wider mb-3">
              Segmented Toggle (Sliding Thumb with Framer Motion layoutId)
            </h4>
            <div className="flex flex-wrap items-center gap-4">
              <SegmentedToggle
                value={segmentedVal}
                onChange={setSegmentedVal}
                options={[
                  { value: "table", label: "Table view", count: 24 },
                  { value: "cards", label: "Card grid" },
                  { value: "calendar", label: "Calendar" },
                ]}
              />

              <SegmentedToggle
                value={dateRangeVal}
                onChange={setDateRangeVal}
                size="sm"
                options={[
                  { value: "7d", label: "7 Days" },
                  { value: "30d", label: "30 Days" },
                  { value: "sem", label: "This Semester" },
                ]}
              />
            </div>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-ink-3 uppercase tracking-wider mb-3">Status Pills</h4>
            <div className="flex flex-wrap items-center gap-2.5">
              <StatusPill status="published" />
              <StatusPill status="draft" />
              <StatusPill status="approved" />
              <StatusPill status="pending" />
              <StatusPill status="rejected" />
              <StatusPill status="waitlisted" />
              <StatusPill status="attended" />
              <StatusPill status="not_attended" />
            </div>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-ink-3 uppercase tracking-wider mb-3">Accent Tokens</h4>
            <div className="flex flex-wrap items-center gap-2">
              <Badge variant="lemon" dot>Lemon Accent</Badge>
              <Badge variant="coral" dot>Coral Accent</Badge>
              <Badge variant="aqua" dot>Aqua Accent</Badge>
              <Badge variant="lavender" dot>Lavender Accent</Badge>
              <Badge variant="mint" dot>Mint Accent</Badge>
            </div>
          </div>
        </Card>
      </section>

      {/* ── 5. KPI StatCards & Analytics ─────────────────────────────────── */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          5. KPI StatCards & <span className="serif-accent font-normal text-brand-blue">Metrics</span>
        </h2>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            variant="brand"
            title="Total Events"
            value={38}
            delta={{ value: 14.2, label: "vs last semester" }}
            subtitle="29 Published • 9 Drafts"
            icon={<Calendar size={18} />}
          />
          <StatCard
            title="Total Registrations"
            value={2480}
            delta={{ value: 28.5, label: "vs last month" }}
            subtitle="Across 14 campus departments"
            icon={<Users size={18} />}
          />
          <StatCard
            title="Live Gate Check-ins"
            value={1892}
            delta={{ value: 18.0 }}
            subtitle="Recorded at entrance scanners"
            icon={<CheckCircle2 size={18} />}
          />
          <StatCard
            title="Attendance Rate"
            value="76.4%"
            delta={{ value: -2.1 }}
            subtitle="Verified student entries"
            icon={<Star size={18} />}
          />
        </div>
      </section>

      {/* ── 6. TanStack DataTable Component ───────────────────────────────── */}
      <section className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-bold tracking-tight text-ink">
            6. TanStack <span className="serif-accent font-normal text-brand-blue">DataTable</span>
          </h2>
          <span className="text-xs text-ink-3">Sticky header • Density toggle • Column chooser • Selection</span>
        </div>

        <DataTable
          columns={sampleColumns}
          data={SAMPLE_DATA}
          searchPlaceholder="Search students by name or roll number..."
          bulkActions={(rows) => (
            <>
              <Button
                size="sm"
                variant="primary"
                onClick={() => toast.success(`Approved ${rows.length} registrations`)}
              >
                Approve
              </Button>
              <Button
                size="sm"
                variant="danger"
                onClick={() => toast.error(`Rejected ${rows.length} registrations`)}
              >
                Reject
              </Button>
            </>
          )}
        />
      </section>

      {/* ── 7. Overlays, Drawers & Dialogs ───────────────────────────────── */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          7. Modals, Drawers & <span className="serif-accent font-normal text-brand-blue">Overlays</span>
        </h2>

        <Card className="p-6">
          <div className="flex flex-wrap items-center gap-3">
            <Button variant="secondary" onClick={() => setDrawerOpen(true)}>
              Open Right Drawer (480px)
            </Button>
            <Button variant="outline" onClick={() => setDialogOpen(true)}>
              Open Standard Dialog
            </Button>
            <Button variant="danger" onClick={() => setConfirmDialogOpen(true)}>
              Open Mascot Confirm Dialog
            </Button>
          </div>
        </Card>
      </section>

      {/* ── 8. Empty States & Skeletons ──────────────────────────────────── */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          8. Empty States & <span className="serif-accent font-normal text-brand-blue">Skeletons</span>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <EmptyState
            title="No registrations yet for this event"
            description="Once students discover this event in the ZEST app and submit their passes, attendee rows will appear here in real time."
            mood="sleepy"
            tint="blue"
            action={<Button size="sm">Copy Student Registration Link</Button>}
          />

          <Card className="p-6 space-y-4">
            <h4 className="text-sm font-bold text-ink">Shimmer Skeletons (No Spinners)</h4>
            <div className="space-y-3">
              <Skeleton className="h-6 w-3/4 rounded-md" />
              <Skeleton className="h-4 w-full rounded-md" />
              <Skeleton className="h-4 w-5/6 rounded-md" />
              <div className="flex gap-2 pt-2">
                <Skeleton className="h-9 w-24 rounded-pill" />
                <Skeleton className="h-9 w-32 rounded-pill" />
              </div>
            </div>
          </Card>
        </div>
      </section>

      {/* ── 9. Keyboard Shortcuts & Hints ───────────────────────────────── */}
      <section className="space-y-4 pb-12">
        <h2 className="text-xl font-bold tracking-tight text-ink">
          9. Keyboard Shortcuts & <span className="serif-accent font-normal text-brand-blue">Tooltips</span>
        </h2>

        <Card className="p-6">
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 text-xs">
            <div className="flex items-center justify-between p-2.5 bg-fill/60 rounded-input border border-line">
              <span className="text-ink-2">Command Palette</span>
              <div className="flex gap-0.5"><Kbd>⌘</Kbd><Kbd>K</Kbd></div>
            </div>

            <div className="flex items-center justify-between p-2.5 bg-fill/60 rounded-input border border-line">
              <span className="text-ink-2">Go to Dashboard</span>
              <div className="flex gap-0.5"><Kbd>G</Kbd><Kbd>D</Kbd></div>
            </div>

            <div className="flex items-center justify-between p-2.5 bg-fill/60 rounded-input border border-line">
              <span className="text-ink-2">Create New Event</span>
              <Kbd>C</Kbd>
            </div>

            <div className="flex items-center justify-between p-2.5 bg-fill/60 rounded-input border border-line">
              <span className="text-ink-2">Quick Search</span>
              <Kbd>/</Kbd>
            </div>
          </div>
        </Card>
      </section>

      {/* Drawer Demo */}
      <Drawer
        isOpen={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        title="Student Registration Details"
        description="Ticket #ZEST-2026-90412"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="secondary" size="sm" onClick={() => setDrawerOpen(false)}>
              Close
            </Button>
            <Button size="sm" onClick={() => { setDrawerOpen(false); toast.success("Pass confirmed"); }}>
              Confirm Pass
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <div className="flex items-center gap-3 p-3 bg-fill/60 rounded-card border border-line">
            <div className="w-12 h-12 rounded-full bg-brand-gradient text-white flex items-center justify-center font-bold text-base">
              A
            </div>
            <div>
              <h4 className="font-bold text-ink">Aarav Sharma</h4>
              <p className="text-xs text-ink-3">Computer Science • Year 3</p>
            </div>
          </div>

          <div className="space-y-2 text-xs">
            <div className="flex justify-between py-1.5 border-b border-line">
              <span className="text-ink-3">Roll / PRN Number</span>
              <span className="font-semibold text-ink">21CS042</span>
            </div>
            <div className="flex justify-between py-1.5 border-b border-line">
              <span className="text-ink-3">Status</span>
              <StatusPill status="approved" size="sm" />
            </div>
            <div className="flex justify-between py-1.5 border-b border-line">
              <span className="text-ink-3">Submission Timestamp</span>
              <span className="font-medium text-ink">Oct 22, 2026, 10:30 AM</span>
            </div>
          </div>
        </div>
      </Drawer>

      {/* Standard Dialog Demo */}
      <Dialog
        isOpen={dialogOpen}
        onClose={() => setDialogOpen(false)}
        title={<span>Invite New <span className="serif-accent font-normal text-brand-blue">Organizer</span></span>}
        description="Send an official email invitation to access the ZEST Admin suite."
      >
        <div className="space-y-4 pt-2">
          <div>
            <label className="text-xs font-semibold text-ink-2 uppercase block mb-1">Faculty / Staff Email</label>
            <Input placeholder="faculty@college.edu" leftIcon={<Mail size={16} />} />
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <Button variant="secondary" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button onClick={() => { setDialogOpen(false); toast.success("Invitation sent"); }}>Send Invite</Button>
          </div>
        </div>
      </Dialog>

      {/* Confirm Dialog Demo */}
      <ConfirmDialog
        isOpen={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
        onConfirm={() => {
          setConfirmDialogOpen(false);
          toast.error("Event deleted");
        }}
        variant="danger"
        mascotMood="celebrate"
        title={<span>Are you <span className="serif-accent font-normal text-semantic-danger">sure</span>?</span>}
        description="Deleting this event draft will permanently remove its form and questions. This action cannot be reversed."
        confirmLabel="Yes, Delete Event"
      />
    </div>
  );
}

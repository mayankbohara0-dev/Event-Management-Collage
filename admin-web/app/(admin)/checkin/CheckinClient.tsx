"use client";

import React, { useState, useEffect, useRef, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  ScanLine,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Zap,
  Users,
  BarChart2,
  ChevronDown,
  RefreshCw,
  Keyboard,
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Select } from "@/components/ui/Select";
import { Input } from "@/components/ui/Input";
import { Badge } from "@/components/ui/Badge";
import { createClient } from "@/lib/supabase/client";
import { Html5QrcodeScanner } from "html5-qrcode";

interface CheckinClientProps {
  events: any[];
  preSelectedEventId: string | null;
  initialStats: { totalApproved: number; checkedIn: number } | null;
  adminId: string;
}

type ScanResult = {
  type: "success" | "already" | "error" | "not_found";
  studentName?: string;
  rollNumber?: string;
  message: string;
  timestamp: Date;
};

export function CheckinClient({
  events,
  preSelectedEventId,
  initialStats,
  adminId,
}: CheckinClientProps) {
  const supabase = createClient();
  const [selectedEventId, setSelectedEventId] = useState(
    preSelectedEventId || ""
  );
  const [stats, setStats] = useState(initialStats);
  const [scanHistory, setScanHistory] = useState<ScanResult[]>([]);
  const [lastScan, setLastScan] = useState<ScanResult | null>(null);
  const [manualCode, setManualCode] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);
  const [scannerMode, setScannerMode] = useState<"camera" | "manual">(
    "manual"
  );
  const scannerRef = useRef<Html5QrcodeScanner | null>(null);
  const qrDivId = "zest-qr-scanner";
  const debounceRef = useRef<NodeJS.Timeout | null>(null);

  const selectedEvent = events.find((e) => e.id === selectedEventId);

  const processQrCode = useCallback(
    async (qrData: string) => {
      if (!selectedEventId) {
        toast.error("Please select an event first.");
        return;
      }
      if (isProcessing) return;
      setIsProcessing(true);

      try {
        // The QR code data is the registration's qr_code_data field
        const { data: registrationData, error } = await (supabase
          .from("registrations") as any)
          .select(
            "id, status, student_id, event_id, student_profiles(name, roll_number)"
          )
          .eq("qr_code_data", qrData)
          .eq("event_id", selectedEventId)
          .maybeSingle();

        const registration = registrationData as any;

        if (error || !registration) {
          const res: ScanResult = {
            type: "not_found",
            message: "QR code not found for this event.",
            timestamp: new Date(),
          };
          setLastScan(res);
          setScanHistory((prev) => [res, ...prev].slice(0, 20));
          setIsProcessing(false);
          return;
        }

        const student = Array.isArray(registration.student_profiles)
          ? registration.student_profiles[0]
          : registration.student_profiles;

        if (registration.status !== "approved") {
          const res: ScanResult = {
            type: "error",
            studentName: student?.name,
            rollNumber: student?.roll_number || undefined,
            message: `Registration is ${registration.status}. Cannot check in.`,
            timestamp: new Date(),
          };
          setLastScan(res);
          setScanHistory((prev) => [res, ...prev].slice(0, 20));
          setIsProcessing(false);
          return;
        }

        // Check if already checked in
        const { data: existing } = await (supabase
          .from("attendance") as any)
          .select("id, check_in_time")
          .eq("registration_id", registration.id)
          .maybeSingle();

        if (existing) {
          const res: ScanResult = {
            type: "already",
            studentName: student?.name,
            rollNumber: student?.roll_number || undefined,
            message: `Already checked in at ${format(new Date(existing.check_in_time), "h:mm a")}`,
            timestamp: new Date(),
          };
          setLastScan(res);
          setScanHistory((prev) => [res, ...prev].slice(0, 20));
          setIsProcessing(false);
          return;
        }

        // Insert attendance record
        const { error: insertError } = await (supabase
          .from("attendance") as any)
          .insert({
            registration_id: registration.id,
            event_id: selectedEventId,
            student_id: registration.student_id,
            method: "qr_scan",
            marked_by: adminId,
          });

        if (insertError) {
          const res: ScanResult = {
            type: "error",
            message: "Failed to record attendance. Try again.",
            timestamp: new Date(),
          };
          setLastScan(res);
          setScanHistory((prev) => [res, ...prev].slice(0, 20));
          setIsProcessing(false);
          return;
        }

        const res: ScanResult = {
          type: "success",
          studentName: student?.name,
          rollNumber: student?.roll_number || undefined,
          message: "Checked in successfully!",
          timestamp: new Date(),
        };
        setLastScan(res);
        setScanHistory((prev) => [res, ...prev].slice(0, 20));
        // Update live stats
        setStats((prev) =>
          prev
            ? { ...prev, checkedIn: prev.checkedIn + 1 }
            : { totalApproved: 1, checkedIn: 1 }
        );
      } finally {
        // Small cooldown to prevent double scans
        setTimeout(() => setIsProcessing(false), 1200);
      }
    },
    [selectedEventId, isProcessing, supabase, adminId]
  );

  // Camera scanner setup
  useEffect(() => {
    if (scannerMode !== "camera" || !selectedEventId) return;

    const scanner = new Html5QrcodeScanner(
      qrDivId,
      {
        fps: 10,
        qrbox: { width: 250, height: 250 },
        rememberLastUsedCamera: true,
      },
      false
    );

    scanner.render(
      (decodedText) => {
        if (debounceRef.current) clearTimeout(debounceRef.current);
        debounceRef.current = setTimeout(() => {
          processQrCode(decodedText);
        }, 300);
      },
      () => {}
    );
    scannerRef.current = scanner;

    return () => {
      scanner.clear().catch(() => {});
    };
  }, [scannerMode, selectedEventId, processQrCode]);

  const handleManualSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!manualCode.trim()) return;
    await processQrCode(manualCode.trim());
    setManualCode("");
  };

  const refreshStats = async () => {
    if (!selectedEventId) return;
    const [{ count: totalApproved }, { count: checkedIn }] = await Promise.all(
      [
        supabase
          .from("registrations")
          .select("*", { count: "exact", head: true })
          .eq("event_id", selectedEventId)
          .eq("status", "approved"),
        supabase
          .from("attendance")
          .select("*", { count: "exact", head: true })
          .eq("event_id", selectedEventId),
      ]
    );
    setStats({ totalApproved: totalApproved ?? 0, checkedIn: checkedIn ?? 0 });
  };

  const attendanceRate =
    stats && stats.totalApproved > 0
      ? Math.round((stats.checkedIn / stats.totalApproved) * 100)
      : 0;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-ink tracking-tight">
          <span className="serif-accent font-normal text-brand-blue">Live</span>{" "}
          Check-in
        </h1>
        <p className="text-sm text-ink-2 mt-1">
          Scan QR codes to mark attendance at the gate.
        </p>
      </div>

      {/* Event Selector */}
      <div className="bg-card rounded-card border border-line p-5">
        <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-2">
          Select Event
        </label>
        <Select
          value={selectedEventId}
          onChange={(e) => {
            setSelectedEventId(e.target.value);
            setStats(null);
            setScanHistory([]);
            setLastScan(null);
          }}
          className="max-w-md"
        >
          <option value="">— Choose an event —</option>
          {events.map((event) => (
            <option key={event.id} value={event.id}>
              {event.title} ·{" "}
              {format(new Date(event.start_date), "d MMM yyyy")}
            </option>
          ))}
        </Select>
      </div>

      {selectedEventId && (
        <>
          {/* Stats Bar */}
          <div className="grid grid-cols-3 gap-4">
            <div className="bg-card rounded-card border border-line p-4 text-center">
              <p className="text-2xl font-bold text-ink tabular-nums">
                {stats?.checkedIn ?? 0}
              </p>
              <p className="text-xs text-ink-2 mt-1">Checked In</p>
            </div>
            <div className="bg-card rounded-card border border-line p-4 text-center relative overflow-hidden">
              <div
                className="absolute bottom-0 left-0 h-1 bg-brand-core transition-all duration-500"
                style={{ width: `${attendanceRate}%` }}
              />
              <p className="text-2xl font-bold text-brand-blue tabular-nums">
                {attendanceRate}%
              </p>
              <p className="text-xs text-ink-2 mt-1">Attendance Rate</p>
            </div>
            <div className="bg-card rounded-card border border-line p-4 text-center">
              <p className="text-2xl font-bold text-ink tabular-nums">
                {stats?.totalApproved ?? 0}
              </p>
              <p className="text-xs text-ink-2 mt-1">Approved Regs</p>
            </div>
          </div>

          {/* Scanner Area */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Scanner */}
            <div className="bg-card rounded-card border border-line p-6 space-y-4">
              <div className="flex items-center justify-between">
                <h2 className="font-semibold text-ink">Scanner</h2>
                <div className="flex gap-2">
                  <button
                    onClick={() => setScannerMode("camera")}
                    className={`text-xs px-3 py-1.5 rounded-pill font-medium transition-colors ${
                      scannerMode === "camera"
                        ? "bg-brand-tint text-brand-blue"
                        : "text-ink-3 hover:text-ink"
                    }`}
                  >
                    Camera
                  </button>
                  <button
                    onClick={() => setScannerMode("manual")}
                    className={`text-xs px-3 py-1.5 rounded-pill font-medium transition-colors ${
                      scannerMode === "manual"
                        ? "bg-brand-tint text-brand-blue"
                        : "text-ink-3 hover:text-ink"
                    }`}
                  >
                    Manual
                  </button>
                </div>
              </div>

              {scannerMode === "camera" ? (
                <div>
                  <div id={qrDivId} className="w-full" />
                </div>
              ) : (
                <form onSubmit={handleManualSubmit} className="space-y-3">
                  <p className="text-xs text-ink-3">
                    Type or paste the QR code value, or use a USB barcode
                    scanner (it acts as a keyboard).
                  </p>
                  <div className="flex gap-2">
                    <Input
                      value={manualCode}
                      onChange={(e) => setManualCode(e.target.value)}
                      placeholder="Paste / scan QR code data…"
                      leftIcon={<Keyboard size={15} />}
                      autoFocus
                    />
                    <Button
                      type="submit"
                      isLoading={isProcessing}
                      leftIcon={<ScanLine size={15} />}
                    >
                      Check In
                    </Button>
                  </div>
                </form>
              )}

              {/* Last Scan Result */}
              <AnimatePresence mode="wait">
                {lastScan && (
                  <motion.div
                    key={lastScan.timestamp.toISOString()}
                    initial={{ opacity: 0, scale: 0.95, y: 10 }}
                    animate={{ opacity: 1, scale: 1, y: 0 }}
                    exit={{ opacity: 0, scale: 0.95 }}
                    transition={{ duration: 0.3 }}
                    className={`rounded-card border p-4 ${
                      lastScan.type === "success"
                        ? "bg-semantic-success/10 border-semantic-success/30"
                        : lastScan.type === "already"
                        ? "bg-brand-tint border-brand-sky/30"
                        : "bg-semantic-danger/10 border-semantic-danger/30"
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <div className="shrink-0 mt-0.5">
                        {lastScan.type === "success" ? (
                          <CheckCircle2
                            size={20}
                            className="text-semantic-success"
                          />
                        ) : lastScan.type === "already" ? (
                          <AlertCircle
                            size={20}
                            className="text-brand-core"
                          />
                        ) : (
                          <XCircle
                            size={20}
                            className="text-semantic-danger"
                          />
                        )}
                      </div>
                      <div>
                        {lastScan.studentName && (
                          <p className="font-semibold text-sm text-ink">
                            {lastScan.studentName}
                            {lastScan.rollNumber && (
                              <span className="font-normal text-ink-2 ml-1">
                                · {lastScan.rollNumber}
                              </span>
                            )}
                          </p>
                        )}
                        <p className="text-sm text-ink-2 mt-0.5">
                          {lastScan.message}
                        </p>
                        <p className="text-[10px] text-ink-3 mt-1">
                          {format(lastScan.timestamp, "h:mm:ss a")}
                        </p>
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>

              <div className="flex items-center justify-between pt-2">
                <p className="text-xs text-ink-3">
                  {scanHistory.length} scans this session
                </p>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={refreshStats}
                  leftIcon={<RefreshCw size={13} />}
                >
                  Refresh stats
                </Button>
              </div>
            </div>

            {/* Scan History */}
            <div className="bg-card rounded-card border border-line p-6">
              <h2 className="font-semibold text-ink mb-4">Scan Log</h2>
              {scanHistory.length === 0 ? (
                <div className="text-center py-16 text-ink-3">
                  <ScanLine size={32} className="mx-auto mb-3 opacity-30" />
                  <p className="text-sm">No scans yet this session.</p>
                </div>
              ) : (
                <div className="space-y-2 max-h-96 overflow-y-auto pr-1">
                  {scanHistory.map((scan, i) => (
                    <motion.div
                      key={i}
                      initial={{ opacity: 0, x: 10 }}
                      animate={{ opacity: 1, x: 0 }}
                      className="flex items-center gap-3 p-2.5 rounded-card bg-fill/50"
                    >
                      <div className="shrink-0">
                        {scan.type === "success" ? (
                          <CheckCircle2
                            size={16}
                            className="text-semantic-success"
                          />
                        ) : scan.type === "already" ? (
                          <AlertCircle
                            size={16}
                            className="text-brand-core"
                          />
                        ) : (
                          <XCircle
                            size={16}
                            className="text-semantic-danger"
                          />
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-xs font-medium text-ink truncate">
                          {scan.studentName || scan.message}
                        </p>
                        {scan.studentName && (
                          <p className="text-[10px] text-ink-3">
                            {scan.message}
                          </p>
                        )}
                      </div>
                      <span className="text-[10px] text-ink-3 shrink-0">
                        {format(scan.timestamp, "h:mm a")}
                      </span>
                    </motion.div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </>
      )}

      {!selectedEventId && (
        <div className="text-center py-24 text-ink-3">
          <ScanLine size={48} className="mx-auto mb-4 opacity-20" />
          <p className="text-base font-medium text-ink-2">
            Select an event to start checking in attendees.
          </p>
        </div>
      )}
    </div>
  );
}

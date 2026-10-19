import React from "react";
import Nav from "@/components/landing/Nav";
import Footer from "@/components/landing/Footer";

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-[var(--page)] flex flex-col">
      <Nav />
      <main className="flex-1 max-w-[800px] mx-auto px-6 pt-[140px] pb-20 text-[var(--ink)]">
        <h1 className="text-[36px] font-bold tracking-tight mb-4">Terms of Service</h1>
        <p className="text-[14px] text-[var(--ink-3)] mb-8">Last updated: October 2026</p>

        <div className="prose text-[16px] leading-relaxed text-[var(--ink-2)] space-y-6">
          <p>
            Welcome to <strong>ZEST</strong>. By accessing or using the ZEST student application or organizer dashboard, you agree to comply with and be bound by these Terms.
          </p>

          <h3 className="text-[20px] font-semibold text-[var(--ink)] mt-6">1. Permitted Campus Use</h3>
          <p>
            ZEST is provided for authorized college clubs, student societies, campus event attendees, and academic departments. Users agree not to forge passes, exploit gate scanners, or submit fraudulent roll numbers.
          </p>

          <h3 className="text-[20px] font-semibold text-[var(--ink)] mt-6">2. Pass Verification & Campus XP</h3>
          <p>
            Event entry and Campus XP distribution require physical check-in and valid QR pass verification at the venue entrance. Organizer check-ins are final and recorded immutably.
          </p>

          <h3 className="text-[20px] font-semibold text-[var(--ink)] mt-6">3. Community Standards</h3>
          <p>
            Clubs publishing events on ZEST must uphold college guidelines and ensure safe and respectful campus environments.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

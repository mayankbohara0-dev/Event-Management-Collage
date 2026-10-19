import React from "react";
import Nav from "@/components/landing/Nav";
import Footer from "@/components/landing/Footer";

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-[var(--page)] flex flex-col">
      <Nav />
      <main className="flex-1 max-w-[800px] mx-auto px-6 pt-[140px] pb-20 text-[var(--ink)]">
        <h1 className="text-[36px] font-bold tracking-tight mb-4">Privacy Policy</h1>
        <p className="text-[14px] text-[var(--ink-3)] mb-8">Last updated: October 2026</p>

        <div className="prose text-[16px] leading-relaxed text-[var(--ink-2)] space-y-6">
          <p>
            At <strong>ZEST</strong>, your privacy is our top priority. We designed ZEST specifically for college campuses with the principle that student data belongs to students and their institutions.
          </p>

          <h3 className="text-[20px] font-semibold text-[var(--ink)] mt-6">1. Information We Collect</h3>
          <p>
            We collect standard campus profile details (name, college email, roll number, department, and graduation year) to verify event attendance and autofill registration forms.
          </p>

          <h3 className="text-[20px] font-semibold text-[var(--ink)] mt-6">2. How We Use Information</h3>
          <p>
            Data is used exclusively to facilitate event registrations, issue digital QR passes, calculate Campus XP, and provide organizers with verified attendance lists. We never sell your personal data to advertisers.
          </p>

          <h3 className="text-[20px] font-semibold text-[var(--ink)] mt-6">3. Security & Storage</h3>
          <p>
            All data is encrypted in transit using TLS 1.3 and at rest with AES-256 encryption. We utilize Supabase infrastructure with strict Row-Level Security policies.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

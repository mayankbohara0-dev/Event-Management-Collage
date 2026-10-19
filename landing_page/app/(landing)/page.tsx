import React from "react";
import Nav from "@/components/landing/Nav";
import Hero from "@/components/landing/Hero";
import HowItWorks from "@/components/landing/HowItWorks";
import Marquee from "@/components/landing/Marquee";
import Story from "@/components/landing/Story";
import FeaturesCarousel from "@/components/landing/FeaturesCarousel";
import Quote from "@/components/landing/Quote";
import Bento from "@/components/landing/Bento";
import PassDemo from "@/components/landing/PassDemo";
import LeaderboardPreview from "@/components/landing/LeaderboardPreview";
import PricingCTA from "@/components/landing/PricingCTA";
import FAQ from "@/components/landing/FAQ";
import FinalCTA from "@/components/landing/FinalCTA";
import Footer from "@/components/landing/Footer";

export default function LandingPage() {
  return (
    <div className="relative min-h-screen bg-[var(--page)] flex flex-col selection:bg-[var(--sky)]/30 selection:text-[var(--ink)]">
      {/* 4.1 Sticky Navigation */}
      <Nav />

      {/* Main Content Sections */}
      <main className="flex-1">
        {/* 4.2 Hero Section */}
        <Hero />

        {/* 4.3 "The way campus events should've been done" */}
        <HowItWorks />

        {/* 4.4 Social proof marquee */}
        <Marquee />

        {/* 4.5 Story card */}
        <Story />

        {/* 4.6 Features carousel — "Everything campus, in one pocket" */}
        <FeaturesCarousel />

        {/* 4.7 Quote */}
        <Quote />

        {/* 4.8 Two-up bento — "For students" / "For organizers" */}
        <Bento />

        {/* 4.9 Interactive pass demo (signature moment) */}
        <PassDemo />

        {/* 4.10 Leaderboard preview */}
        <LeaderboardPreview />

        {/* 4.11 Pricing-style CTA */}
        <PricingCTA />

        {/* 4.12 FAQ — "Frequently asked questions" */}
        <FAQ />

        {/* 4.13 Final CTA (dark) */}
        <FinalCTA />
      </main>

      {/* 4.14 Footer */}
      <Footer />
    </div>
  );
}

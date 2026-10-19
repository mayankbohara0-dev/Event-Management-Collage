"use client";

import React from "react";
import BlobLogo from "@/components/brand/BlobLogo";
import { landingData } from "@/lib/landing-data";

export default function Footer() {
  const { brandName, tagline, links, madeBy, copyrightYear } = landingData.footer;

  return (
    <footer className="bg-white border-t border-[var(--line)] py-10 sm:py-12 text-[var(--ink)]">
      <div className="max-w-[1200px] mx-auto px-5 sm:px-6">
        <div className="flex flex-col items-center sm:flex-row sm:items-center justify-between gap-5 sm:gap-6 pb-6 sm:pb-8 border-b border-[var(--line)]">
          {/* Logo & Tagline */}
          <div className="flex items-center gap-3">
            <BlobLogo size={32} />
            <div>
              <span className="font-semibold text-[20px] tracking-tight lowercase text-[var(--ink)] block">
                {brandName}
              </span>
              <span className="text-[13px] text-[var(--ink-3)] block">
                {tagline}
              </span>
            </div>
          </div>

          {/* Links */}
          <div className="flex items-center gap-6 text-[14px] font-medium text-[var(--ink-2)]">
            {links.map((link) => (
              <a
                key={link.label}
                href={link.href}
                className="hover:text-[var(--blue)] transition-colors no-underline"
              >
                {link.label}
              </a>
            ))}
          </div>
        </div>

        {/* Bottom Credits & Copyright */}
        <div className="pt-6 flex flex-col sm:flex-row items-center justify-between gap-3 text-[13px] text-[var(--ink-3)]">
          <p>{madeBy}</p>
          <p>© {copyrightYear} ZEST. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}

"use client";

import React, { useState } from "react";
import { Sidebar } from "./Sidebar";
import { TopBar } from "./TopBar";

interface AppShellProps {
  children: React.ReactNode;
  user?: {
    name?: string;
    email?: string;
    role?: string;
    avatarUrl?: string;
  };
}

export function AppShell({ children, user }: AppShellProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-page flex">
      {/* Desktop/Tablet Left Sidebar */}
      <Sidebar user={user} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 pl-16 md:pl-[76px] lg:pl-[248px] transition-all duration-300">
        <TopBar
          user={user}
          onMobileMenuToggle={() => setMobileMenuOpen(!mobileMenuOpen)}
        />
        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-[1280px] w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

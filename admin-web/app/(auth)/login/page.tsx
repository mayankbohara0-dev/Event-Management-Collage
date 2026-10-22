"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Mail, Lock, ArrowRight } from "lucide-react";
import { toast } from "sonner";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { Mascot } from "@/components/brand/Mascot";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      toast.error("Please enter both email and password");
      return;
    }

    setIsLoading(true);

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        toast.error(error.message || "Invalid credentials");
        setIsLoading(false);
        return;
      }

      if (data.session) {
        // Verify admin profile server check
        const { data: profile } = await supabase
          .from("admin_profiles")
          .select("id, role")
          .eq("id", data.session.user.id)
          .maybeSingle();

        const p = profile as { id: string; role: string } | null;

        if (!p || (p.role !== "admin" && p.role !== "super_admin")) {
          toast.error("This account does not have admin permissions.");
          router.push("/unauthorized");
          return;
        }

        toast.success("Welcome back to ZEST Admin!");
        router.push("/dashboard");
        router.refresh();
      }
    } catch {
      toast.error("An unexpected error occurred. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-page flex items-center justify-center p-4 lg:p-8">
      <div className="w-full max-w-5xl bg-card rounded-hero border border-line shadow-floating overflow-hidden grid grid-cols-1 lg:grid-cols-2 min-h-[600px]">
        {/* Left: Brand Mesh Gradient Panel with Peeking Mascot */}
        <div className="relative p-8 lg:p-12 bg-gradient-to-br from-brand-sky/20 via-brand-tint/60 to-brand-blue/20 flex flex-col justify-between overflow-hidden border-b lg:border-b-0 lg:border-r border-line">
          {/* Subtle animated drifting background blobs */}
          <motion.div
            animate={{
              x: [0, 20, 0],
              y: [0, -15, 0],
            }}
            transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
            className="absolute -top-16 -left-16 w-64 h-64 rounded-full bg-brand-sky/30 blur-3xl pointer-events-none"
          />
          <motion.div
            animate={{
              x: [0, -25, 0],
              y: [0, 20, 0],
            }}
            transition={{ duration: 7, repeat: Infinity, ease: "easeInOut" }}
            className="absolute -bottom-16 -right-16 w-72 h-72 rounded-full bg-brand-blue/25 blur-3xl pointer-events-none"
          />

          {/* Top Logo */}
          <div className="relative z-10 flex items-center gap-3">
            <BlobLogo size={42} />
            <span className="font-bold text-xl tracking-tight text-ink">
              zest <span className="font-normal text-xs text-brand-core font-mono">admin</span>
            </span>
          </div>

          {/* Center Mascot & Headline */}
          <div className="relative z-10 my-12 text-center lg:text-left">
            <div className="inline-block mb-6">
              <Mascot size={110} mood="happy" tint="blue" />
            </div>

            <h1 className="text-3xl lg:text-4xl font-bold text-ink tracking-tight leading-tight">
              Run campus events{" "}
              <span className="serif-accent font-normal text-brand-blue">
                without the chaos
              </span>
              .
            </h1>
            <p className="mt-3 text-sm text-ink-2 max-w-md">
              Control registrations, manage forms, scan passes live at the gate, and
              export university accreditation reports in seconds.
            </p>
          </div>

          {/* Bottom Chip */}
          <div className="relative z-10 flex items-center gap-2 text-xs font-semibold text-brand-blueDeep">
            <span className="w-2 h-2 rounded-full bg-brand-core animate-pulse" />
            <span>Built exclusively for university organizers</span>
          </div>
        </div>

        {/* Right: Sign In Form */}
        <div className="p-8 lg:p-12 flex flex-col justify-between">
          <div className="max-w-md w-full mx-auto my-auto">
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-ink tracking-tight">
                Sign in to your account
              </h2>
              <p className="text-xs text-ink-2 mt-1.5">
                Enter your organizer credentials to access the console.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                  Email Address
                </label>
                <Input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="organizer@college.edu"
                  leftIcon={<Mail size={16} />}
                  required
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1.5">
                  <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider">
                    Password
                  </label>
                  <Link
                    href="/forgot-password"
                    className="text-xs font-medium text-brand-blue hover:underline"
                  >
                    Forgot password?
                  </Link>
                </div>
                <Input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  leftIcon={<Lock size={16} />}
                  required
                />
              </div>

              <div className="pt-2">
                <Button
                  type="submit"
                  fullWidth
                  size="lg"
                  isLoading={isLoading}
                  rightIcon={<ArrowRight size={16} />}
                >
                  Sign in
                </Button>
              </div>
            </form>
          </div>

          {/* Footnote: Invite only notice */}
          <div className="pt-6 border-t border-line text-center text-xs text-ink-3">
            <span>Need access? </span>
            <span className="text-ink-2 font-medium">
              Ask your campus super admin for an invitation.
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

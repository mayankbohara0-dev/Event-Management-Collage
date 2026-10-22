"use client";

import React, { useState } from "react";
import Link from "next/link";
import { Mail, ArrowLeft, ArrowRight } from "lucide-react";
import { toast } from "sonner";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";

export default function ForgotPasswordPage() {
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;

    setIsLoading(true);

    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      if (error) {
        toast.error(error.message);
        setIsLoading(false);
        return;
      }

      setSubmitted(true);
      toast.success("Password reset instructions sent to your email");
    } catch {
      toast.error("An error occurred. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-page flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-card rounded-card border border-line shadow-floating p-8">
        <div className="mb-6 text-center">
          <div className="inline-block mb-3">
            <BlobLogo size={48} />
          </div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            Reset your password
          </h1>
          <p className="text-xs text-ink-2 mt-1">
            We will send a secure link to your verified organizer email.
          </p>
        </div>

        {submitted ? (
          <div className="text-center py-4 space-y-4">
            <div className="p-4 bg-brand-tint/50 border border-brand-core/20 rounded-input text-xs text-brand-blue font-medium">
              Check your inbox at <strong>{email}</strong> for instructions to reset your password.
            </div>
            <Link href="/login">
              <Button variant="secondary" fullWidth leftIcon={<ArrowLeft size={16} />}>
                Back to Sign in
              </Button>
            </Link>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                Organizer Email
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

            <Button
              type="submit"
              fullWidth
              size="lg"
              isLoading={isLoading}
              rightIcon={<ArrowRight size={16} />}
            >
              Send reset link
            </Button>

            <div className="text-center pt-2">
              <Link
                href="/login"
                className="inline-flex items-center gap-1.5 text-xs text-ink-3 hover:text-ink transition-colors"
              >
                <ArrowLeft size={14} /> Back to Sign in
              </Link>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}

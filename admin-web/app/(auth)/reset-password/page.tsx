"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Lock, ArrowRight } from "lucide-react";
import { toast } from "sonner";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";

export default function ResetPasswordPage() {
  const router = useRouter();
  const supabase = createClient();
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    }
    if (password.length < 8) {
      toast.error("Password must be at least 8 characters long");
      return;
    }

    setIsLoading(true);

    try {
      const { error } = await supabase.auth.updateUser({ password });

      if (error) {
        toast.error(error.message);
        setIsLoading(false);
        return;
      }

      toast.success("Password updated successfully! Please sign in.");
      router.push("/login");
    } catch {
      toast.error("Failed to update password");
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
            Set new password
          </h1>
          <p className="text-xs text-ink-2 mt-1">
            Choose a strong password for your organizer account.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              New Password
            </label>
            <Input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••••••"
              leftIcon={<Lock size={16} />}
              required
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              Confirm New Password
            </label>
            <Input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="••••••••••••"
              leftIcon={<Lock size={16} />}
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
            Update password
          </Button>
        </form>
      </div>
    </div>
  );
}

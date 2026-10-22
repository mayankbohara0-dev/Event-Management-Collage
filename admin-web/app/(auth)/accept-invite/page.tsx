"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { User, Lock, ArrowRight } from "lucide-react";
import { toast } from "sonner";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { Mascot } from "@/components/brand/Mascot";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";

export default function AcceptInvitePage() {
  const router = useRouter();
  const supabase = createClient();

  const [name, setName] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      toast.error("Please enter your full name");
      return;
    }
    if (password.length < 8) {
      toast.error("Password must be at least 8 characters");
      return;
    }

    setIsLoading(true);

    try {
      // 1. Update auth password
      const { data: authData, error: authError } = await supabase.auth.updateUser({
        password,
      });

      if (authError || !authData.user) {
        toast.error(authError?.message || "Invalid or expired invite token");
        setIsLoading(false);
        return;
      }

      await (supabase.from("admin_profiles") as any)
        .update({ name: name.trim() })
        .eq("id", authData.user.id);

      toast.success("Account setup complete! Welcome to the team.");
      router.push("/dashboard");
      router.refresh();
    } catch {
      toast.error("An error occurred during account setup");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-page flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-card rounded-card border border-line shadow-floating p-8 text-center">
        <div className="flex justify-center mb-4">
          <BlobLogo size={48} />
        </div>
        <div className="w-20 h-20 mx-auto mb-4 flex items-center justify-center">
          <Mascot size={74} mood="celebrate" tint="lemon" />
        </div>

        <h1 className="text-2xl font-bold text-ink tracking-tight">
          Accept your <span className="serif-accent font-normal text-brand-blue">invitation</span>
        </h1>
        <p className="text-xs text-ink-2 mt-1 mb-6">
          Set up your organizer profile to join your college event team.
        </p>

        <form onSubmit={handleSubmit} className="space-y-4 text-left">
          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              Your Full Name
            </label>
            <Input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Prof. Alex Smith"
              leftIcon={<User size={16} />}
              required
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              Choose Password
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

          <Button
            type="submit"
            fullWidth
            size="lg"
            isLoading={isLoading}
            rightIcon={<ArrowRight size={16} />}
          >
            Activate account
          </Button>
        </form>
      </div>
    </div>
  );
}

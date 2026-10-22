"use client";

import React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { LogOut, ExternalLink } from "lucide-react";
import { toast } from "sonner";
import { Mascot } from "@/components/brand/Mascot";
import { BlobLogo } from "@/components/brand/BlobLogo";
import { Button } from "@/components/ui/Button";
import { createClient } from "@/lib/supabase/client";

export default function UnauthorizedPage() {
  const router = useRouter();
  const supabase = createClient();

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    toast.success("Signed out");
    router.push("/login");
  };

  return (
    <div className="min-h-screen bg-page flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-card rounded-card border border-line shadow-floating p-8 text-center">
        <div className="flex justify-center mb-4">
          <BlobLogo size={48} />
        </div>
        <div className="w-24 h-24 mx-auto mb-4 flex items-center justify-center">
          <Mascot size={88} mood="sleepy" tint="coral" />
        </div>

        <h1 className="text-2xl font-bold text-ink tracking-tight mb-2">
          No admin access <span className="serif-accent font-normal text-semantic-danger">found</span>
        </h1>

        <p className="text-sm text-ink-2 mb-6">
          This account is registered as a student and does not have organizer or
          administrator privileges for ZEST Admin.
        </p>

        <div className="space-y-3">
          <Button
            variant="outline"
            fullWidth
            onClick={handleSignOut}
            leftIcon={<LogOut size={16} />}
          >
            Sign out & switch account
          </Button>

          <a
            href="/"
            target="_blank"
            rel="noopener noreferrer"
            className="block"
          >
            <Button
              variant="secondary"
              fullWidth
              rightIcon={<ExternalLink size={15} />}
            >
              Open student web portal
            </Button>
          </a>
        </div>
      </div>
    </div>
  );
}

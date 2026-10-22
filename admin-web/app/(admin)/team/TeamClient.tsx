"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  ShieldCheck,
  Shield,
  Building2,
  MoreHorizontal,
  Crown,
  UserPlus,
  Trash2,
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

interface TeamClientProps {
  team: any[];
  departments: any[];
  currentUserId: string;
}

function RoleBadge({ role }: { role: string }) {
  if (role === "super_admin")
    return (
      <Badge variant="warning" size="sm">
        Super Admin
      </Badge>
    );
  return <Badge variant="default" size="sm">Admin</Badge>;
}

export function TeamClient({
  team,
  departments,
  currentUserId,
}: TeamClientProps) {
  const supabase = createClient();
  const router = useRouter();
  const [removingId, setRemovingId] = useState<string | null>(null);
  const [promotingId, setPromotingId] = useState<string | null>(null);

  const handleRemove = async (memberId: string, name: string) => {
    if (memberId === currentUserId) {
      toast.error("You cannot remove yourself.");
      return;
    }
    if (!confirm(`Remove ${name} from the team?`)) return;
    setRemovingId(memberId);
    const { error } = await supabase
      .from("admin_profiles")
      .delete()
      .eq("id", memberId);
    setRemovingId(null);
    if (error) {
      toast.error("Failed to remove member.");
    } else {
      toast.success(`${name} removed.`);
      router.refresh();
    }
  };

  const handleRoleToggle = async (
    memberId: string,
    currentRole: string,
    name: string
  ) => {
    if (memberId === currentUserId) {
      toast.error("You cannot change your own role.");
      return;
    }
    const nextRole = currentRole === "super_admin" ? "admin" : "super_admin";
    if (!confirm(`Change ${name}'s role to ${nextRole}?`)) return;
    setPromotingId(memberId);
    const { error } = await (supabase
      .from("admin_profiles") as any)
      .update({ role: nextRole })
      .eq("id", memberId);
    setPromotingId(null);
    if (error) {
      toast.error("Failed to update role.");
    } else {
      toast.success(`${name} is now ${nextRole}.`);
      router.refresh();
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            <span className="serif-accent font-normal text-brand-blue">
              Team
            </span>
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            {team.length} organizer{team.length !== 1 ? "s" : ""}
          </p>
        </div>
        <div className="bg-brand-tint border border-brand-sky/30 rounded-card px-4 py-2.5 text-xs text-brand-blue font-medium">
          Invite via Supabase Auth → send magic link to new organizer
        </div>
      </div>

      {/* Team Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {team.map((member) => {
          const dept = Array.isArray(member.departments)
            ? member.departments[0]
            : member.departments;
          const isCurrentUser = member.id === currentUserId;

          return (
            <motion.div
              key={member.id}
              layout
              initial={{ opacity: 0, scale: 0.97 }}
              animate={{ opacity: 1, scale: 1 }}
              className={`bg-card rounded-card border p-5 ${
                isCurrentUser ? "border-brand-blue/30" : "border-line"
              }`}
            >
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-brand-gradient text-white flex items-center justify-center text-sm font-bold shrink-0">
                    {member.name[0].toUpperCase()}
                  </div>
                  <div>
                    <div className="flex items-center gap-1.5">
                      <p className="text-sm font-semibold text-ink">
                        {member.name}
                      </p>
                      {isCurrentUser && (
                        <span className="text-[9px] font-bold bg-brand-tint text-brand-blue px-1.5 py-0.5 rounded-full uppercase">
                          You
                        </span>
                      )}
                    </div>
                    <RoleBadge role={member.role} />
                  </div>
                </div>

                {!isCurrentUser && (
                  <div className="flex gap-1">
                    <button
                      onClick={() =>
                        handleRoleToggle(member.id, member.role, member.name)
                      }
                      disabled={promotingId === member.id}
                      className="p-1.5 rounded-card text-ink-3 hover:text-brand-blue hover:bg-brand-tint transition-colors"
                      title="Toggle role"
                    >
                      <Crown size={14} />
                    </button>
                    <button
                      onClick={() => handleRemove(member.id, member.name)}
                      disabled={removingId === member.id}
                      className="p-1.5 rounded-card text-ink-3 hover:text-semantic-danger hover:bg-semantic-danger/10 transition-colors"
                      title="Remove member"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                )}
              </div>

              <div className="mt-4 pt-4 border-t border-line space-y-1.5">
                {dept && (
                  <div className="flex items-center gap-2 text-xs text-ink-2">
                    <Building2 size={12} className="text-ink-3" />
                    <span>
                      {dept.name} ({dept.code})
                    </span>
                  </div>
                )}
                <div className="flex items-center gap-2 text-xs text-ink-3">
                  <ShieldCheck size={12} />
                  <span>
                    Joined {format(new Date(member.created_at), "d MMM yyyy")}
                  </span>
                </div>
              </div>
            </motion.div>
          );
        })}
      </div>

      {/* How to Invite Info Box */}
      <div className="bg-fill rounded-card border border-line p-6">
        <h2 className="text-sm font-semibold text-ink mb-2 flex items-center gap-2">
          <UserPlus size={16} className="text-brand-core" />
          How to invite a new organizer
        </h2>
        <ol className="text-sm text-ink-2 space-y-1.5 list-decimal list-inside">
          <li>
            Go to <strong>Supabase Dashboard → Auth → Users → Invite User</strong>
          </li>
          <li>Enter the organizer&apos;s email address</li>
          <li>
            They&apos;ll receive a magic link; upon sign-in, their{" "}
            <code className="text-xs bg-fill px-1 py-0.5 rounded">
              admin_profiles
            </code>{" "}
            row is created automatically
          </li>
          <li>Come back here and set their department / role</li>
        </ol>
      </div>
    </div>
  );
}

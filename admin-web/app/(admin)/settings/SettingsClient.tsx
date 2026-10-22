"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { User, Lock, Save, Eye, EyeOff } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { BlobLogo } from "@/components/brand/BlobLogo";

interface SettingsClientProps {
  profile: any;
  email: string;
}

export function SettingsClient({ profile, email }: SettingsClientProps) {
  const supabase = createClient();
  const router = useRouter();
  const [name, setName] = useState(profile?.name || "");
  const [savingProfile, setSavingProfile] = useState(false);
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);

  const dept = Array.isArray(profile?.departments)
    ? profile?.departments[0]
    : profile?.departments;

  const handleSaveProfile = async () => {
    if (!name.trim()) {
      toast.error("Name cannot be empty.");
      return;
    }
    setSavingProfile(true);
    const { error } = await (supabase
      .from("admin_profiles") as any)
      .update({ name: name.trim() })
      .eq("id", profile?.id);
    setSavingProfile(false);
    if (error) {
      toast.error("Failed to save profile.");
    } else {
      toast.success("Profile updated.");
      router.refresh();
    }
  };

  const handleChangePassword = async () => {
    if (!newPassword) {
      toast.error("Please enter a new password.");
      return;
    }
    if (newPassword.length < 8) {
      toast.error("Password must be at least 8 characters.");
      return;
    }
    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match.");
      return;
    }
    setSavingPassword(true);
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    setSavingPassword(false);
    if (error) {
      toast.error("Failed to update password: " + error.message);
    } else {
      toast.success("Password changed successfully.");
      setNewPassword("");
      setConfirmPassword("");
    }
  };

  return (
    <div className="space-y-6 max-w-2xl">
      <div>
        <h1 className="text-2xl font-bold text-ink tracking-tight">
          <span className="serif-accent font-normal text-brand-blue">
            Settings
          </span>
        </h1>
        <p className="text-sm text-ink-2 mt-1">
          Manage your account and preferences.
        </p>
      </div>

      {/* Profile Section */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-card rounded-card border border-line p-6 space-y-5"
      >
        <div className="flex items-center gap-3 border-b border-line pb-4">
          <User size={16} className="text-brand-core" />
          <h2 className="text-sm font-semibold text-ink">Profile</h2>
        </div>

        {/* Avatar + info */}
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-full bg-brand-gradient text-white flex items-center justify-center text-xl font-bold">
            {name ? name[0].toUpperCase() : "A"}
          </div>
          <div>
            <p className="text-sm font-semibold text-ink">{name || "Organizer"}</p>
            <p className="text-xs text-ink-3">{email}</p>
            {profile?.role && (
              <span className="text-[10px] font-bold uppercase tracking-wider text-brand-core">
                {profile.role.replace("_", " ")}
              </span>
            )}
          </div>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              Display Name
            </label>
            <Input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Your name"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              Email Address
            </label>
            <Input value={email} disabled />
            <p className="text-xs text-ink-3 mt-1">
              Email cannot be changed here. Contact your Supabase admin.
            </p>
          </div>

          {dept && (
            <div>
              <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
                Department
              </label>
              <Input value={`${dept.name} (${dept.code})`} disabled />
            </div>
          )}
        </div>

        <Button
          onClick={handleSaveProfile}
          isLoading={savingProfile}
          leftIcon={<Save size={15} />}
        >
          Save Profile
        </Button>
      </motion.div>

      {/* Password Section */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="bg-card rounded-card border border-line p-6 space-y-5"
      >
        <div className="flex items-center gap-3 border-b border-line pb-4">
          <Lock size={16} className="text-brand-core" />
          <h2 className="text-sm font-semibold text-ink">Change Password</h2>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              New Password
            </label>
            <div className="relative">
              <Input
                type={showPassword ? "text" : "password"}
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="Min. 8 characters"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-ink-3 hover:text-ink transition-colors"
              >
                {showPassword ? <EyeOff size={15} /> : <Eye size={15} />}
              </button>
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold text-ink-2 uppercase tracking-wider mb-1.5">
              Confirm Password
            </label>
            <Input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Repeat new password"
            />
          </div>
        </div>

        <Button
          onClick={handleChangePassword}
          isLoading={savingPassword}
          variant="outline"
          leftIcon={<Lock size={15} />}
        >
          Change Password
        </Button>
      </motion.div>

      {/* App Info */}
      <div className="bg-fill rounded-card border border-line p-5 flex items-center gap-4">
        <BlobLogo size={36} />
        <div>
          <p className="text-sm font-semibold text-ink">ZEST Admin</p>
          <p className="text-xs text-ink-3">
            Built for campus organizers. Powered by Supabase.
          </p>
        </div>
      </div>
    </div>
  );
}

"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plus, Building2, Pencil, Trash2, Users, Check, X } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import { format } from "date-fns";

interface DepartmentsClientProps {
  departments: any[];
  studentCountByDept: Record<string, number>;
}

export function DepartmentsClient({
  departments,
  studentCountByDept,
}: DepartmentsClientProps) {
  const supabase = createClient();
  const router = useRouter();
  const [creating, setCreating] = useState(false);
  const [newName, setNewName] = useState("");
  const [newCode, setNewCode] = useState("");
  const [saving, setSaving] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editName, setEditName] = useState("");
  const [editCode, setEditCode] = useState("");
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleCreate = async () => {
    if (!newName.trim() || !newCode.trim()) {
      toast.error("Name and code are required.");
      return;
    }
    setSaving(true);
    const { error } = await (supabase.from("departments") as any).insert({
      name: newName.trim(),
      code: newCode.trim().toUpperCase(),
    });
    setSaving(false);
    if (error) {
      toast.error("Failed to create department: " + error.message);
    } else {
      toast.success("Department created.");
      setCreating(false);
      setNewName("");
      setNewCode("");
      router.refresh();
    }
  };

  const startEdit = (dept: any) => {
    setEditingId(dept.id);
    setEditName(dept.name);
    setEditCode(dept.code);
  };

  const saveEdit = async (id: string) => {
    setSaving(true);
    const { error } = await (supabase
      .from("departments") as any)
      .update({ name: editName.trim(), code: editCode.trim().toUpperCase() })
      .eq("id", id);
    setSaving(false);
    if (error) {
      toast.error("Failed to update.");
    } else {
      toast.success("Updated.");
      setEditingId(null);
      router.refresh();
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Delete department "${name}"? This may affect student profiles.`))
      return;
    setDeletingId(id);
    const { error } = await supabase
      .from("departments")
      .delete()
      .eq("id", id);
    setDeletingId(null);
    if (error) {
      toast.error("Failed to delete: " + error.message);
    } else {
      toast.success("Department deleted.");
      router.refresh();
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-ink tracking-tight">
            <span className="serif-accent font-normal text-brand-blue">
              Departments
            </span>
          </h1>
          <p className="text-sm text-ink-2 mt-1">
            {departments.length} department{departments.length !== 1 ? "s" : ""}
          </p>
        </div>
        <Button
          leftIcon={<Plus size={15} />}
          onClick={() => setCreating(true)}
        >
          Add Department
        </Button>
      </div>

      {/* Create Form */}
      <AnimatePresence>
        {creating && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="bg-card rounded-card border border-brand-blue/20 p-5"
          >
            <h2 className="text-sm font-semibold text-ink mb-4">
              New Department
            </h2>
            <div className="flex flex-col sm:flex-row gap-3">
              <Input
                placeholder="Department name (e.g., Computer Science)"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                className="flex-1"
              />
              <Input
                placeholder="Code (e.g., CS)"
                value={newCode}
                onChange={(e) => setNewCode(e.target.value)}
                className="sm:w-32"
              />
              <Button onClick={handleCreate} isLoading={saving}>
                Create
              </Button>
              <Button
                variant="ghost"
                onClick={() => {
                  setCreating(false);
                  setNewName("");
                  setNewCode("");
                }}
              >
                Cancel
              </Button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Departments Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {departments.map((dept) => (
          <motion.div
            key={dept.id}
            layout
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="bg-card rounded-card border border-line p-5"
          >
            {editingId === dept.id ? (
              <div className="space-y-2">
                <Input
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  placeholder="Department name"
                />
                <Input
                  value={editCode}
                  onChange={(e) => setEditCode(e.target.value)}
                  placeholder="Code"
                />
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    isLoading={saving}
                    onClick={() => saveEdit(dept.id)}
                    leftIcon={<Check size={13} />}
                  >
                    Save
                  </Button>
                  <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => setEditingId(null)}
                    leftIcon={<X size={13} />}
                  >
                    Cancel
                  </Button>
                </div>
              </div>
            ) : (
              <>
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-card bg-brand-tint flex items-center justify-center shrink-0">
                      <Building2 size={18} className="text-brand-blue" />
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-ink">
                        {dept.name}
                      </p>
                      <span className="text-xs font-mono font-bold text-brand-core bg-brand-tint px-1.5 py-0.5 rounded">
                        {dept.code}
                      </span>
                    </div>
                  </div>
                  <div className="flex gap-1">
                    <button
                      onClick={() => startEdit(dept)}
                      className="p-1.5 rounded-card text-ink-3 hover:text-brand-blue hover:bg-brand-tint transition-colors"
                    >
                      <Pencil size={14} />
                    </button>
                    <button
                      onClick={() => handleDelete(dept.id, dept.name)}
                      disabled={deletingId === dept.id}
                      className="p-1.5 rounded-card text-ink-3 hover:text-semantic-danger hover:bg-semantic-danger/10 transition-colors"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
                <div className="mt-4 pt-4 border-t border-line flex items-center gap-3 text-xs text-ink-3">
                  <div className="flex items-center gap-1.5">
                    <Users size={12} />
                    <span>
                      {studentCountByDept[dept.id] || 0} students
                    </span>
                  </div>
                  <span>·</span>
                  <span>
                    Added {format(new Date(dept.created_at), "d MMM yyyy")}
                  </span>
                </div>
              </>
            )}
          </motion.div>
        ))}
      </div>
    </div>
  );
}

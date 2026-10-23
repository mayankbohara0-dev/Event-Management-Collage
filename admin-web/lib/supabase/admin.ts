import { createClient as createSupabaseClient } from "@supabase/supabase-js";
import { Database } from "@/lib/database.types";

const FALLBACK_URL = "https://fgdrvtonfgeuboggucoe.supabase.co";
const FALLBACK_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnZHJ2dG9uZmdldWJvZ2d1Y29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQyNzAsImV4cCI6MjEwMTY3MDI3MH0.A7Oghf0CjCjZKEmZ5PqhHKXLXP86MaPUWFMy_aoVaJM";

export function createAdminClient() {
  let supabaseUrl = (process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || "").trim().replace(/^["']|["']$/g, "");
  let serviceRoleKey = (process.env.SUPABASE_SERVICE_ROLE_KEY || "").trim().replace(/^["']|["']$/g, "");

  if (!supabaseUrl || supabaseUrl.includes("dummy") || supabaseUrl.includes("your-project") || supabaseUrl.includes("fgdrvtongfeuboggucoc")) {
    supabaseUrl = FALLBACK_URL;
  }

  if (!serviceRoleKey || !serviceRoleKey.startsWith("eyJ")) {
    serviceRoleKey = FALLBACK_KEY;
  }

  return createSupabaseClient<Database>(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

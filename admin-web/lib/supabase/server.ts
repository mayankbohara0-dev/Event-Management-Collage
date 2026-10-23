import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { Database } from "@/lib/database.types";

const FALLBACK_URL = "https://fgdrvtonfgeuboggucoe.supabase.co";
const FALLBACK_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnZHJ2dG9uZmdldWJvZ2d1Y29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQyNzAsImV4cCI6MjEwMTY3MDI3MH0.A7Oghf0CjCjZKEmZ5PqhHKXLXP86MaPUWFMy_aoVaJM";

function cleanConfig() {
  let url = (process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || "").trim().replace(/^["']|["']$/g, "");
  let key = (process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY || "").trim().replace(/^["']|["']$/g, "");

  if (!url || url.includes("dummy") || url.includes("your-project") || url.includes("fgdrvtongfeuboggucoc")) {
    url = FALLBACK_URL;
  }

  if (!key || !key.startsWith("eyJ") || key.includes("dummy")) {
    key = FALLBACK_KEY;
  }

  return { url, key };
}

export function createClient() {
  const cookieStore = cookies();
  const { url, key } = cleanConfig();

  return createServerClient<Database>(url, key, {
    cookies: {
      get(name: string) {
        return cookieStore.get(name)?.value;
      },
      set(name: string, value: string, options: CookieOptions) {
        try {
          cookieStore.set({ name, value, ...options });
        } catch {
          // Can happen in Server Components (read-only cookie store)
        }
      },
      remove(name: string, options: CookieOptions) {
        try {
          cookieStore.set({ name, value: "", ...options });
        } catch {
          // Can happen in Server Components
        }
      },
    },
  });
}

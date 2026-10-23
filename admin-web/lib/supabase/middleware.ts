import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import { Database } from "@/lib/database.types";

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  });

  const FALLBACK_URL = "https://fgdrvtonfgeuboggucoe.supabase.co";
  const FALLBACK_KEY =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnZHJ2dG9uZmdldWJvZ2d1Y29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQyNzAsImV4cCI6MjEwMTY3MDI3MH0.A7Oghf0CjCjZKEmZ5PqhHKXLXP86MaPUWFMy_aoVaJM";

  let supabaseUrl = (process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || "").trim().replace(/^["']|["']$/g, "");
  let supabaseAnonKey = (process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY || "").trim().replace(/^["']|["']$/g, "");

  if (!supabaseUrl || supabaseUrl.includes("dummy") || supabaseUrl.includes("your-project") || supabaseUrl.includes("fgdrvtongfeuboggucoc")) {
    supabaseUrl = FALLBACK_URL;
  }

  if (!supabaseAnonKey || !supabaseAnonKey.startsWith("eyJ") || supabaseAnonKey.includes("dummy")) {
    supabaseAnonKey = FALLBACK_KEY;
  }

  const supabase = createServerClient<Database>(supabaseUrl, supabaseAnonKey, {
    cookies: {
      get(name: string) {
        return request.cookies.get(name)?.value;
      },
      set(name: string, value: string, options: CookieOptions) {
        request.cookies.set({
          name,
          value,
          ...options,
        });
        response = NextResponse.next({
          request: {
            headers: request.headers,
          },
        });
        response.cookies.set({
          name,
          value,
          ...options,
        });
      },
      remove(name: string, options: CookieOptions) {
        request.cookies.set({
          name,
          value: "",
          ...options,
        });
        response = NextResponse.next({
          request: {
            headers: request.headers,
          },
        });
        response.cookies.set({
          name,
          value: "",
          ...options,
        });
      },
    },
  });

  const pathname = request.nextUrl.pathname;

  // Static files and internal Next.js paths
  if (
    pathname.startsWith("/_next") ||
    pathname.startsWith("/api/health") ||
    pathname.includes(".")
  ) {
    return response;
  }

  // Allow /dev/gallery publicly for design system inspection
  if (pathname.startsWith("/dev/gallery")) {
    return response;
  }

  // Public auth paths
  const isAuthRoute =
    pathname === "/login" ||
    pathname === "/forgot-password" ||
    pathname === "/reset-password" ||
    pathname === "/accept-invite" ||
    pathname === "/unauthorized";

  const {
    data: { session },
  } = await supabase.auth.getSession();

  // If not authenticated and trying to access protected admin pages
  if (!session && !isAuthRoute) {
    const redirectUrl = new URL("/login", request.url);
    if (pathname !== "/") {
      redirectUrl.searchParams.set("returnTo", pathname);
    }
    return NextResponse.redirect(redirectUrl);
  }

  // If authenticated and accessing login or root page
  if (session) {
    // Check if user is an admin in admin_profiles
    const { data: adminProfile } = await supabase
      .from("admin_profiles")
      .select("id, role")
      .eq("id", session.user.id)
      .maybeSingle();

    const p = adminProfile as { id: string; role: string } | null;
    const isAdmin =
      p && (p.role === "admin" || p.role === "super_admin");

    if (!isAdmin && pathname !== "/unauthorized") {
      return NextResponse.redirect(new URL("/unauthorized", request.url));
    }

    if (isAdmin && (pathname === "/login" || pathname === "/")) {
      return NextResponse.redirect(new URL("/dashboard", request.url));
    }
  }

  return response;
}

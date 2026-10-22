import type { Metadata, Viewport } from "next";
import { Toaster } from "sonner";
import "./globals.css";
import { QueryProvider } from "@/components/providers/QueryProvider";

export const metadata: Metadata = {
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3001"
  ),
  title: "ZEST Admin — Campus Event Control Panel",
  description: "The official organizer control panel for ZEST campus events.",
  manifest: "/manifest.json",
  icons: {
    icon: [
      { url: "/zest_app_icon.png", type: "image/png", sizes: "any" },
    ],
    apple: "/zest_app_icon.png",
    shortcut: "/zest_app_icon.png",
  },
  openGraph: {
    title: "ZEST Admin",
    description: "Campus event control panel for organizers.",
    images: [{ url: "/zest_app_icon.png", width: 512, height: 512 }],
  },
};

export const viewport: Viewport = {
  themeColor: "#0AA5F0",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
      </head>
      <body className="min-h-screen bg-page text-ink selection:bg-brand-tint selection:text-brand-blue">
        <QueryProvider>
          {children}
          <Toaster
            position="top-right"
            richColors
            closeButton
            toastOptions={{
              style: {
                borderRadius: "16px",
                border: "1px solid #E6EAF2",
                boxShadow: "0 10px 30px rgba(11, 18, 32, 0.08)",
                fontFamily: "var(--font-inter)",
              },
            }}
          />
        </QueryProvider>
      </body>
    </html>
  );
}

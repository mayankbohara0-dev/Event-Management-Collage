import type { Metadata } from "next";
import { Inter, Instrument_Serif } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const instrumentSerif = Instrument_Serif({
  subsets: ["latin"],
  weight: "400",
  style: ["normal", "italic"],
  variable: "--font-instrument-serif",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://zestcampus.app"),
  title: "ZEST — Campus events, passes & XP",
  description:
    "Find events, grab an animated QR pass and earn XP for showing up. One unified app for college students and club organizers instead of forms, forwards and paper lists.",
  keywords: [
    "ZEST",
    "campus events",
    "college event management",
    "QR tickets",
    "campus XP",
    "student life app",
    "college clubs",
    "attendance scanner",
  ],
  authors: [{ name: "ZEST Team" }],
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "ZEST",
    startupImage: "/apple-touch-icon.png",
  },
  openGraph: {
    title: "ZEST — Campus events, passes & XP",
    description: "Add some zest to your campus life. Event discovery, digital QR passes, and real-time gate scanner.",
    url: "https://zestcampus.app",
    siteName: "ZEST",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "ZEST — College Event Management & Student Life",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "ZEST — Campus events, passes & XP",
    description: "Add some zest to your campus life. Event discovery, digital QR passes, and real-time gate scanner.",
    images: ["/og-image.png"],
  },
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/favicon-16x16.png", sizes: "16x16", type: "image/png" },
      { url: "/favicon-32x32.png", sizes: "32x32", type: "image/png" },
      { url: "/favicon-48x48.png", sizes: "48x48", type: "image/png" },
      { url: "/icon-192x192.png", sizes: "192x192", type: "image/png" },
      { url: "/icon-512x512.png", sizes: "512x512", type: "image/png" },
    ],
    shortcut: "/favicon-32x32.png",
    apple: [
      { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
    ],
    other: [
      { rel: "mask-icon", url: "/favicon.svg", color: "#0063F0" },
    ],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: "ZEST",
    operatingSystem: "iOS, Android, Web",
    applicationCategory: "LifestyleApplication",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
    },
    description:
      "College event management and student life app featuring instant QR passes, Campus XP, live leaderboards, and an organizer suite.",
  };

  return (
    <html lang="en" className={`${inter.variable} ${instrumentSerif.variable} scroll-smooth`}>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        {/* PWA & Mobile App Meta */}
        <meta name="theme-color" content="#0063F0" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="msapplication-TileColor" content="#0063F0" />
        <meta name="msapplication-TileImage" content="/icon-192x192.png" />
      </head>
      <body className="min-h-screen bg-[var(--page)] text-[var(--ink)] font-sans antialiased selection:bg-[var(--sky)]/30 selection:text-[var(--ink)]">
        {children}
      </body>
    </html>
  );
}

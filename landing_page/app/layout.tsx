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
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
    apple: "/apple-touch-icon.png",
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
      </head>
      <body className="min-h-screen bg-[var(--page)] text-[var(--ink)] font-sans antialiased selection:bg-[var(--sky)]/30 selection:text-[var(--ink)]">
        {children}
      </body>
    </html>
  );
}

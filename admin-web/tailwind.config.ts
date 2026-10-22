import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./features/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          sky: "#38BDF8",
          core: "#0AA5F0",
          blue: "#0063F0",
          blueDeep: "#0050C8",
          tint: "#E6F4FE",
        },
        ink: {
          DEFAULT: "#0B1220",
          2: "#5B6577",
          3: "#8A93A5",
        },
        page: "#F5F7FB",
        card: "#FFFFFF",
        line: "#E6EAF2",
        fill: "#EEF2F8",
        semantic: {
          success: "#16B364",
          "success-tint": "rgba(22, 179, 100, 0.12)",
          warning: "#F59E0B",
          "warning-tint": "rgba(245, 158, 11, 0.12)",
          danger: "#EF4444",
          "danger-tint": "rgba(239, 68, 68, 0.12)",
        },
        accent: {
          lemon: "#FFD84D",
          coral: "#FF6B8A",
          aqua: "#6CE3FF",
          lavender: "#8E8BEA",
          mint: "#3DDC97",
        },
      },
      fontFamily: {
        sans: ["var(--font-inter)", "sans-serif"],
        serif: ["var(--font-instrument-serif)", "serif"],
      },
      borderRadius: {
        card: "24px",
        hero: "32px",
        input: "14px",
        pill: "9999px",
      },
      boxShadow: {
        floating: "0 10px 30px rgba(11, 18, 32, 0.06)",
        hairline: "0 0 0 1px rgba(230, 234, 242, 1)",
        card: "0 4px 16px rgba(11, 18, 32, 0.08)",
      },
      transitionTimingFunction: {
        zest: "cubic-bezier(0.22, 1, 0.36, 1)",
      },
      transitionDuration: {
        fast: "180ms",
        normal: "320ms",
        slow: "600ms",
      },
      backgroundImage: {
        "brand-gradient": "linear-gradient(180deg, #38BDF8 0%, #0063F0 100%)",
        "brand-mesh": "radial-gradient(at 0% 0%, #E6F4FE 0px, transparent 50%), radial-gradient(at 100% 100%, #38BDF8 0px, transparent 50%)",
      },
    },
  },
  plugins: [],
};

export default config;

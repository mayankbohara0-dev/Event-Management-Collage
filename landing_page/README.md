# 🍋 ZEST — Landing Page

> Premium, calm, modern product landing page for **ZEST** ("Add some zest to your campus life") — college event management and student life app. Built with Next.js 14+ (App Router), TypeScript, Tailwind CSS, and Framer Motion in the spirit of Designjoy.

---

## 🚀 Quick Start (Local Development)

```bash
# Navigate to landing_page folder
cd landing_page

# Install dependencies (if not already installed)
npm install

# Run the local development server
npm run dev

# Open http://localhost:3000 in your browser
```

To create a production static build:

```bash
npm run build
npm run start
```

---

## 📂 Architecture & File Map

```text
landing_page/
├── app/
│   ├── (landing)/
│   │   └── page.tsx           # Main landing page combining all sections in sequence
│   ├── privacy/
│   │   └── page.tsx           # Privacy Policy page
│   ├── terms/
│   │   └── page.tsx           # Terms of Service page
│   ├── globals.css            # Design tokens, CSS variables, keyframe animations
│   └── layout.tsx             # Root layout with Inter & Instrument Serif fonts, SEO & schema
├── components/
│   ├── brand/
│   │   ├── BlobLogo.tsx       # Exact SVG squircle lemon logo with glow filters
│   │   ├── Mascot.tsx         # Interactive mascot (eye blinks, cursor tracking, tints)
│   │   ├── MeshCard.tsx       # 4 Recipe mesh gradient cards (Sky, Sunset, Violet, Mint)
│   │   ├── MagneticButton.tsx # Magnetic cursor hover & press-squish buttons
│   │   └── SectionHeading.tsx # Mask-up word reveals + single italic serif accent word
│   └── landing/
│       ├── Nav.tsx            # Sticky navigation with scroll indicator & mobile sheet
│       ├── Hero.tsx           # Hero section with mock phone, chips, and mascot
│       ├── HowItWorks.tsx     # 3 tall gradient workflow cards with mini UIs
│       ├── Marquee.tsx        # Infinite clubs marquee with edge fade masks
│       ├── Story.tsx          # Word-by-word scroll opacity reveal card
│       ├── FeaturesCarousel.tsx # Horizontal snap carousel with glossy glass tiles
│       ├── Quote.tsx          # Instrument Serif quote testimonial
│       ├── Bento.tsx          # Two-up bento (fanning screens & organizer pill cloud)
│       ├── PassDemo.tsx       # Interactive QR ticket, laser sweep, +80 XP confetti
│       ├── LeaderboardPreview.tsx # Podium & reordering live campus ranks
│       ├── PricingCTA.tsx     # Designjoy-style Sky mesh card + dark organizer card
│       ├── FAQ.tsx            # Single-open accordion + sticky contact box
│       ├── FinalCTA.tsx       # Dark section, calendar card & 7 bouncing mascots
│       └── Footer.tsx         # Logo, credits, legal links, and copyright
└── lib/
    ├── landing-data.ts        # ⭐ ALL copy, stats, FAQ, and placeholders live here!
    └── motion.ts              # Framer motion variants, easing, and reduced-motion fallback
```

---

## ✏️ How to Edit Copy & Replace Placeholders

**You do NOT need to touch JSX components to edit text or numbers.**
All content is centralized in [`lib/landing-data.ts`](lib/landing-data.ts).

Search for `// TODO` in [`lib/landing-data.ts`](lib/landing-data.ts) to find and replace placeholders:

1. **Store Links / App Downloads**:
   - `landingData.navigation.ctaPrimary.href`
   - `landingData.hero.ctaPrimary.href`
   - `landingData.pricing.cards.studentCard.href`
2. **Organizer Inquiries & Contact Email**:
   - `landingData.faq.contactBox.email` (default: `hello@zestcampus.app`)
   - `landingData.footer.links`
3. **Clubs / Societies**:
   - `landingData.socialProof.clubs` (edit names to match your campus clubs)
4. **Testimonials**:
   - `landingData.quote` (replace with student council lead or fest convenor quote)
5. **Pricing / Pilot Plan**:
   - `landingData.pricing.cards.organizerCard` (update pricing tiers or campus pilot statements)

---

## 🎨 Design Tokens

- **Sky**: `#38BDF8`
- **Core Blue**: `#0AA5F0`
- **Deep Blue**: `#0063F0` / `#0050C8`
- **Ink (Text & Dark Cards)**: `#0B1220`
- **Page Canvas**: `#F5F7FB`
- **Playful Accents**: Lemon (`#FFD84D`), Coral (`#FF6B8A`), Aqua (`#6CE3FF`), Lavender (`#8E8BEA`), Mint (`#3DDC97`)
- **Typography**: Inter (Body/UI) + **Instrument Serif Italic** for the single accent word in each heading.

---

## 🌐 Deploy to Vercel

### Option 1: Vercel CLI

```bash
cd landing_page
npx vercel
```

### Option 2: GitHub Integration

1. Push this repository to GitHub.
2. In the [Vercel Dashboard](https://vercel.com/dashboard), click **Add New Project**.
3. Select your repository.
4. Set the **Root Directory** to `landing_page`.
5. Click **Deploy**. Vercel will automatically build and deploy the Next.js static site.

# 🍋 Zest — Landing Page

> Bold, fast, Gen-Z campus event landing page built around the signature **Zest Lime & Cropped Z** logo.

---

## 🚀 Quick Start (No Build Step)

This is a vanilla HTML5 / CSS3 / JavaScript static site. You can run it with any static web server:

```bash
# Using Python
python -m http.server 3000

# Using Node / npx
npx serve .
```

Open `http://localhost:3000` in your browser.

---

## 🎨 Brand System & Design Tokens

All tokens are defined in [`css/tokens.css`](css/tokens.css):

| Variable | Value | Purpose |
|---|---|---|
| `--color-lime-1` | `#C2FF3A` | Primary neon lime gradient start |
| `--color-lime-2` | `#7DFF2A` | Primary neon lime gradient end |
| `--color-lime-flat` | `#B8FF1A` | Solid lime fallback |
| `--color-ink` | `#141416` | Main dark background & text color |
| `--color-offwhite` | `#F4F5EF` | Light background canvas |
| `--font-display` | `Bricolage Grotesque` | Heavy display headings |
| `--font-body` | `Inter` | Clean readable body copy |

### Contrast Rules
- **Black text on lime ALWAYS** (`#141416` on `#B8FF1A`). Never white text on lime.
- **White text on dark sections** (`#FFFFFF` on `#141416`).

---

## 📂 File Architecture

```
landing_page/
├── index.html           # Main 14-section landing page
├── privacy.html         # Privacy Policy
├── terms.html           # Terms of Service
├── assets/              # Vector SVGs, icons, and logo
│   ├── logo.svg         # Clean vector logo (cropped Z + sparkle)
│   ├── sparkle.svg      # 4-point twinkle sparkle
│   └── logo.png         # High-resolution raster app icon
├── css/
│   ├── tokens.css       # Design variables, fluid clamps
│   ├── base.css         # Reset, grain noise overlay, typography
│   ├── components.css   # Navbar, buttons, cursor, modal, stickers
│   ├── animations.css   # Keyframes, marquees, reduced-motion overrides
│   └── sections.css     # 14 distinct page sections
└── js/
    ├── main.js          # Controller, dark mode toggle, FAQ accordion
    ├── intro.js         # Quick <1.2s logo entrance animation
    ├── scroll.js        # Text scrub reveal, step tracker, stats counter
    ├── forms.js         # Waitlist validation, confetti, modal focus trap
    └── cursor.js        # Magnetic interactive lime dot cursor
```

---

## 🔌 Wiring the Waitlist to Supabase

To store waitlist signups directly in Supabase:
1. Create a `waitlist` table in Supabase:
   ```sql
   create table waitlist (
     id uuid primary key default uuid_generate_v4(),
     email text unique not null,
     created_at timestamptz default now()
   );
   alter table waitlist enable row level security;
   create policy "Allow anonymous inserts" on waitlist for insert with check (true);
   ```
2. In [`js/forms.js`](js/forms.js), add a `fetch` POST request to your Supabase REST endpoint:
   ```javascript
   await fetch('https://YOUR_PROJECT.supabase.co/rest/v1/waitlist', {
     method: 'POST',
     headers: {
       'apikey': 'YOUR_ANON_KEY',
       'Content-Type': 'application/json'
     },
     body: JSON.stringify({ email: emailInput.value })
   });
   ```

---

## 🚢 Deployment

### Netlify / Vercel
Simply drag and drop the `landing_page` directory into Netlify, or push to GitHub and set the publish directory to `landing_page`.

### GitHub Pages
1. Go to repository **Settings** → **Pages**.
2. Select branch and specify `/landing_page` folder (or copy contents to `docs/`).

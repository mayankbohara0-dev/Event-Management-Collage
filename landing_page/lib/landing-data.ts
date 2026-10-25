/**
 * ZEST LANDING PAGE DATA SOURCE
 * 
 * ALL copy, statistics, club lists, features, FAQ, and placeholders live here.
 * You can edit any text or numbers below without touching JSX components.
 * 
 * Marked placeholders (// TODO) can be replaced with production values.
 */

export interface DiscoverCardData {
  id: "discover";
  mesh: "sky";
  number: string;
  step: string;
  title: string;
  description: string;
  previewData: {
    categories: string[];
    upcomingEvent: {
      title: string;
      club: string;
      seatsProgress: number;
      seatsText: string;
      badge: string;
    };
  };
}

export interface RegisterCardData {
  id: "register";
  mesh: "violet";
  number: string;
  step: string;
  title: string;
  description: string;
  previewData: {
    fields: { label: string; value: string }[];
    buttonState: string;
  };
}

export interface GetInCardData {
  id: "get-in";
  mesh: "sunset";
  number: string;
  step: string;
  title: string;
  description: string;
  previewData: {
    ticketCode: string;
    xpGain: string;
    scanTime: string;
    verifiedText: string;
  };
}

export interface NavLink {
  label: string;
  href: string;
}

export interface ClubPill {
  name: string;
  category: string;
}

export interface FeatureItem {
  id: string;
  iconName: string;
  title: string;
  description: string;
  badge?: string;
}

export interface LeaderboardUser {
  id: string;
  rank: number;
  name: string;
  tag: string;
  xp: number;
  avatarSeed: string;
  streak: number;
  level: number;
}

export interface FAQItem {
  id: string;
  question: string;
  answer: string;
}

export interface CalendarEvent {
  day: number;
  title: string;
  time: string;
  venue: string;
  xp: number;
  category: string;
}

export const APP_DOWNLOAD_URL =
  "https://github.com/mayankbohara0-dev/Event-Management-Collage/releases/tag/release-v1.0.0";

export const landingData = {
  // Navigation
  navigation: {
    brandName: "zest",
    tagline: "Add some zest to your campus life",
    links: [
      { label: "How it works", href: "#how-it-works" },
      { label: "Features", href: "#features" },
      { label: "Organizers", href: "#organizers" },
      { label: "FAQ", href: "#faq" },
    ] as NavLink[],
    ctaSecondary: {
      label: "I'm an organizer",
      href: "#organizers",
    },
    ctaPrimary: {
      label: "Get the app",
      href: "#get-app",
    },
  },

  // Hero Section
  hero: {
    eyebrow: "Campus events, sorted",
    headingParts: {
      prefix: "Campus life, with a ",
      accent: "twist",
      suffix: ".",
    },
    subtitle:
      "Find events, grab a QR pass and earn XP for showing up. One app instead of forms, forwards and paper lists.",
    ctaPrimary: {
      label: "Get the app",
      href: APP_DOWNLOAD_URL,
    },
    ctaSecondary: {
      label: "I'm an organizer",
      href: "#organizers",
    },
    microcopy: "Free for students · Built for colleges", // TODO: Update college / rollout tagline if needed
    floatingChips: [
      { id: "pass", text: "Pass verified ✓", color: "sky" },
      { id: "xp", text: "+80 XP", color: "mint" },
      { id: "spots", text: "5 spots left ⚡", color: "lemon" },
    ],
    mockPhone: {
      user: {
        name: "Aarav Sharma",
        level: 4,
        xp: 1420,
        nextLevelXp: 2000,
        avatarSeed: "aarav",
      },
      chips: ["All", "Tech", "Cultural", "Sports", "Workshops"],
      featuredEvent: {
        title: "HackCampus '26 Grand Finale",
        club: "Tech & Code Society",
        date: "Tomorrow, 5:30 PM",
        venue: "Auditorium Hall A",
        seatsLeft: 8,
        totalSeats: 250,
        xpReward: 80,
        status: "Going ✓",
      },
      secondaryEvent: {
        title: "Sunset Acoustic Open Mic",
        club: "Music Guild",
        date: "Fri, 6:00 PM",
        seatsLeft: 14,
        totalSeats: 120,
        xpReward: 50,
        status: "Reserve",
      },
    },
  },

  // How It Works ("The way campus events should've been done")
  howItWorks: {
    eyebrow: "THE WORKFLOW",
    headingParts: {
      prefix: "The way campus events ",
      accent: "should've",
      suffix: " been done",
    },
    subtitle:
      "No messy WhatsApp broadcast groups, no endless Google Sheets, no lost paper registers.",
    cards: [
      {
        id: "discover",
        mesh: "sky" as const,
        number: "01",
        step: "Discover",
        title: "Browse every club in one live feed",
        description:
          "Browse every club, workshop and fest in one feed. Filter by category, search instantly, and never miss an announcement.",
        previewData: {
          categories: ["Tech Club", "Dance Crew", "Quiz Soc", "Robotics", "E-Cell", "Fine Arts"],
          upcomingEvent: {
            title: "RoboWars Arena 2026",
            club: "Robotics Club",
            seatsProgress: 88,
            seatsText: "12 seats remaining",
            badge: "Trending",
          },
        },
      },
      {
        id: "register",
        mesh: "violet" as const,
        number: "02",
        step: "Register",
        title: "One tap or quick dynamic form",
        description:
          "One tap or a quick form — your details autofill from your profile. Instant auto-approval or organizer review.",
        previewData: {
          fields: [
            { label: "Name", value: "Mayank Bohara" },
            { label: "Roll Number", value: "22BCS1048" },
            { label: "Team Name", value: "ByteForce" },
          ],
          buttonState: "You're in!",
        },
      },
      {
        id: "get-in",
        mesh: "sunset" as const,
        number: "03",
        step: "Get in",
        title: "Show your pass. Scanned in under a second.",
        description:
          "Show your pass. Scanned in under a second. High-speed gate check-in with duplicate-entry protection and +80 XP awarded on entry.",
        previewData: {
          ticketCode: "ZEST-2026-X94B",
          xpGain: "+80 XP",
          scanTime: "0.4s",
          verifiedText: "Verified Entry",
        },
      },
    ],
  },

  // Social Proof Marquee
  socialProof: {
    heading: "Run by clubs across campus",
    // TODO: Replace with exact names of clubs active on your campus
    clubs: [
      { name: "Tech & Coding Club", category: "Technical" },
      { name: "Cultural Committee", category: "Arts" },
      { name: "Sports Council", category: "Athletics" },
      { name: "Design & UX Society", category: "Creative" },
      { name: "Quiz Society", category: "Academic" },
      { name: "Robotics & IoT Lab", category: "Technical" },
      { name: "Music Guild", category: "Arts" },
      { name: "Entrepreneurship Cell", category: "Business" },
      { name: "Photography Club", category: "Media" },
      { name: "Literary & Debate Society", category: "Literary" },
      { name: "Hackathons & Devs", category: "Technical" },
      { name: "Dramatics Club", category: "Theatre" },
    ] as ClubPill[],
  },

  // Story Card (Why ZEST exists)
  story: {
    eyebrow: "OUR STORY",
    // Text reveals word by word in ink as user scrolls
    lines: [
      "College events were trapped in messy Google Forms, dead WhatsApp forwards, and crumpled paper lists where attendance always vanished.",
      "We built ZEST from a dorm desk so campus life feels like 2026: one clean home feed, instant QR entry at the door, and real XP for showing up.",
      "Built by a student, designed for colleges, and completely free for every student on campus.",
    ],
    author: "Built by students, for students.",
  },

  // Features Carousel ("Everything campus, in one pocket")
  features: {
    eyebrow: "WHY ZEST",
    headingParts: {
      prefix: "Everything campus, ",
      accent: "in one pocket",
      suffix: "",
    },
    subtitle:
      "All the tools students need to participate, and every power tool organizers need to run flawless events.",
    items: [
      {
        id: "instant-pass",
        iconName: "QrCode",
        title: "Instant QR Pass",
        description:
          "Interactive animated ticket with live countdown, seat numbers, and offline verification.",
        badge: "Zero Paper",
      },
      {
        id: "custom-forms",
        iconName: "SlidersHorizontal",
        title: "Custom Dynamic Forms",
        description:
          "Organizers build forms in seconds; students autofill verified roll numbers and team names in one tap.",
        badge: "Autofill",
      },
      {
        id: "campus-xp",
        iconName: "Sparkles",
        title: "Campus XP & Levels",
        description:
          "Earn +80 XP every time you check in at the gate. Level up your student profile and unlock campus badges.",
        badge: "Gamified",
      },
      {
        id: "live-leaderboard",
        iconName: "Trophy",
        title: "Live Campus Leaderboard",
        description:
          "Weekly and all-time rankings across batches and houses. Friendly competition that drives turnout.",
        badge: "Real-time",
      },
      {
        id: "calendar-sync",
        iconName: "CalendarCheck",
        title: "Calendar Sync & Countdown",
        description:
          "Add approved events directly to Google Calendar or Apple Calendar with live time-remaining countdowns.",
        badge: "Never Miss",
      },
      {
        id: "attendance-record",
        iconName: "ShieldCheck",
        title: "Verified Attendance Record",
        description:
          "Proof of event participation with gate-scanned timestamps, exportable for faculty credit and certificates.",
        badge: "Tamper-proof",
      },
    ] as FeatureItem[],
  },

  // Testimonial / Quote
  quote: {
    // TODO: Replace with real testimonial from student body president or club lead
    text:
      "“We stopped losing attendance registers and chasing people for Google Forms. At our annual fest, 1,400 students walked in with ZEST passes in under 20 minutes.”",
    author: {
      name: "Rohan Varma",
      role: "Convenor, Annual Campus Fest 2026",
      avatarInitials: "RV",
      avatarBg: "#0AA5F0",
    },
  },

  // Two-up Bento ("For students" / "For organizers")
  bento: {
    headingParts: {
      prefix: "Two sides. ",
      accent: "One unified",
      suffix: " campus.",
    },
    subtitle: "A delightful app for students, and a military-grade control room for club leads.",
    students: {
      title: "For Students",
      tagline: "Explore, show up, collect badges, and climb the campus leaderboard.",
      cta: "Explore student app",
      screens: [
        { title: "Home Feed", subtitle: "Live events & category chips" },
        { title: "My Passes", subtitle: "Animated QR & check-in status" },
        { title: "Leaderboard", subtitle: "Weekly podium & batch ranking" },
      ],
      features: [
        "Home feed with live search & chips",
        "Campus XP, streaks & achievement badges",
        "Seats-left progress bars & alerts",
        "Interactive digital pass with QR ticket",
        "Add-to-calendar & live countdowns",
      ],
    },
    organizers: {
      title: "For Organizers & Clubs",
      tagline: "Throw out paper lists and WhatsApp broadcasts for good.",
      cta: "See organizer tools",
      pills: [
        { label: "Dashboard Metrics", icon: "BarChart3" },
        { label: "Event Creator", icon: "PlusCircle" },
        { label: "No-Code Form Builder", icon: "Sliders" },
        { label: "Gate QR Scanner", icon: "ScanLine" },
        { label: "Attendee Table", icon: "Users" },
        { label: "CSV Export", icon: "Download" },
        { label: "Auto-Approval Toggle", icon: "CheckCircle2" },
        { label: "Duplicate Entry Guard", icon: "ShieldAlert" },
        { label: "+80 XP Gate Dispatch", icon: "Zap" },
      ],
      features: [
        "Create events and ticket types in 90 seconds",
        "No-code form builder (roll validation, file uploads)",
        "Gate scanner with flashlight toggle & duplicate lock",
        "One-click CSV exports for college administration",
      ],
    },
  },

  // Interactive Pass Demo (Signature Moment)
  passDemo: {
    eyebrow: "SIGNATURE EXPERIENCE",
    headingParts: {
      prefix: "Your pass. ",
      accent: "Scanned in a blink",
      suffix: ".",
    },
    subtitle:
      "Try the interactive gate check-in demo below. Click 'Scan it' to simulate how club coordinators verify entry at the venue door.",
    ticket: {
      eventName: "ZEST Hackathon '26 · Main Arena",
      college: "CAMPUS CODE FESTIVAL",
      attendee: "Aarav Sharma",
      rollNo: "22BCS1048",
      date: "Saturday, Oct 24, 2026",
      time: "09:30 AM IST",
      venue: "Tech Innovation Hub — Auditorium 02",
      ticketId: "ZEST-8902-XQ7",
      xpValue: 80,
    },
  },

  // Leaderboard Preview
  leaderboard: {
    eyebrow: "COMPETITION & REWARDS",
    headingParts: {
      prefix: "Show up. ",
      accent: "Level up",
      suffix: ".",
    },
    subtitle:
      "Every hackathon, cultural night, sports match, and workshop you attend adds XP to your student profile.",
    bullets: [
      {
        title: "Weekly & All-time Rankings",
        desc: "Compete with your batchmates, hostel wings, or departments.",
      },
      {
        title: "+80 XP For Every Event",
        desc: "Instant XP injection verified straight from the gate scanner.",
      },
      {
        title: "Unlock Campus Badges",
        desc: "Earn titles like 'Fest Veteran', 'Code Warrior', and 'Night Owl'.",
      },
    ],
    podium: [
      {
        rank: 1,
        name: "Devina K.",
        xp: 3240,
        level: 8,
        tag: "CS '25",
        badge: "Crown",
        avatarSeed: "devina",
      },
      {
        rank: 2,
        name: "Arjun Nair",
        xp: 2980,
        level: 7,
        tag: "EE '26",
        badge: "Silver",
        avatarSeed: "arjun",
      },
      {
        rank: 3,
        name: "Priya S.",
        xp: 2750,
        level: 7,
        tag: "Mech '26",
        badge: "Bronze",
        avatarSeed: "priya",
      },
    ],
    rankingRows: [
      { id: "u4", rank: 4, name: "Kabir Mehta", tag: "Civil '27", xp: 2410, streak: 5, level: 6 },
      { id: "u5", rank: 5, name: "Ananya Roy", tag: "Design '26", xp: 2280, streak: 4, level: 6 },
      { id: "u6", rank: 6, name: "Tanmay Rao", tag: "CS '27", xp: 2150, streak: 3, level: 5 },
      { id: "u7", rank: 7, name: "Sneha Patel", tag: "Biotech '25", xp: 1980, streak: 6, level: 5 },
    ],
  },

  // Pricing / CTA (Designjoy style two cards)
  pricing: {
    eyebrow: "GET STARTED",
    headingParts: {
      prefix: "Simple plans for ",
      accent: "every campus",
      suffix: ".",
    },
    cards: {
      studentCard: {
        title: "Join ZEST",
        price: "Free",
        period: "forever for students",
        description: "Download the app, discover all campus events, grab QR passes, and earn XP.",
        cta: "Download student app",
        href: APP_DOWNLOAD_URL,
        highlights: [
          "Unlimited event discoveries",
          "One-tap autofill registrations",
          "Interactive QR ticket wallet",
          "XP levels, streaks & badges",
          "Sync with Google & Apple Calendar",
        ],
      },
      organizerCard: {
        title: "For clubs & colleges",
        // TODO: Replace with actual pricing tier or free campus pilot statement
        price: "Free to start",
        period: "campus pilot edition",
        description: "Everything campus clubs, councils, and college departments need to run events.",
        cta: "Request organizer access",
        // TODO: Replace with organizer registration / demo link
        href: "#contact",
        highlightsCol1: [
          "Unlimited club events",
          "No-code dynamic form builder",
          "High-speed gate QR scanner",
        ],
        highlightsCol2: [
          "1-click CSV attendee exports",
          "Automated roll-number check",
          "Real-time attendance metrics",
        ],
      },
    },
    infoTiles: [
      {
        title: "Set up in minutes",
        description: "Clubs can create their first event in under 90 seconds without admin training.",
      },
      {
        title: "Your data stays yours",
        description: "College data is private, encrypted, and never sold to third-party advertisers.",
      },
    ],
  },

  // FAQ Section
  faq: {
    eyebrow: "GOT QUESTIONS?",
    headingParts: {
      prefix: "Frequently asked ",
      accent: "questions",
      suffix: "",
    },
    subtitle: "Everything you need to know about ZEST for students and club organizers.",
    // Contact card on right
    contactBox: {
      title: "Questions? Talk to us.",
      description: "Need custom integration for your college festival, club council, or faculty approvals?",
      // TODO: Replace with team email address
      email: "hello@zestcampus.app",
      cta: "Drop an email",
    },
    questions: [
      {
        id: "faq-1",
        question: "How do I get my pass?",
        answer:
          "Open the ZEST app, browse the home feed, tap on an event, and hit 'Get Pass'. If the event requires details, your roll number and name are autofilled from your profile. Your animated QR pass is immediately saved to 'My Passes' and works offline.",
      },
      {
        id: "faq-2",
        question: "Do I need to pay for ZEST as a student?",
        answer:
          "Never. ZEST is 100% free for college students. You get full access to the home feed, passes, leaderboard, calendar sync, and XP rewards.",
      },
      {
        id: "faq-3",
        question: "How does Campus XP work?",
        answer:
          "Every time an organizer scans your pass at the gate, your account is credited with +80 XP. As you collect XP, your student profile levels up from Level 1 (Fresher) to higher tier titles and unlocks badges displayed on the campus leaderboard.",
      },
      {
        id: "faq-4",
        question: "Who can create events?",
        answer:
          "Verified club leaders, student council members, societies, and department heads. Organizers have access to the web dashboard and organizer suite to publish events, customize forms, and deploy gate scanners.",
      },
      {
        id: "faq-5",
        question: "What happens when an event is full?",
        answer:
          "Each event displays a live seats-left progress bar. Once capacity is reached, registration automatically locks, preventing over-booking and fire-safety hazards in halls.",
      },
      {
        id: "faq-6",
        question: "Can I add events to my calendar?",
        answer:
          "Yes! Every event detail screen includes an 'Add to Calendar' button that seamlessly syncs with Apple Calendar, Google Calendar, and Outlook with notifications.",
      },
      {
        id: "faq-7",
        question: "How does the gate scanner stop duplicate entries?",
        answer:
          "Our scanner decodes the cryptographically signed ticket ID. The moment a pass is scanned, the server flags it as checked-in in real-time. If someone screenshots the pass and shares it, the scanner triggers an instant duplicate-entry alert and locks entry.",
      },
      {
        id: "faq-8",
        question: "Is my college data safe?",
        answer:
          "Yes. Student roll numbers, attendance records, and organizer lists are encrypted in transit and at rest using enterprise-grade Supabase security with strict Row-Level Security (RLS). We never sell student data.",
      },
    ] as FAQItem[],
  },

  // Final CTA Section (Dark Ink Section)
  finalCta: {
    headingParts: {
      prefix: "See if ZEST fits your campus ",
      accent: "(it totally does)",
      suffix: "",
    },
    subtitle:
      "Get the app on your phone today or book a 10-minute demo for your club council or college administration.",
    ctaPrimary: {
      label: "Get the student app",
      href: APP_DOWNLOAD_URL,
    },
    ctaSecondary: {
      label: "Book club demo",
      // TODO: Replace with booking / calendar link
      href: "#contact",
    },
    calendarWidget: {
      month: "October 2026",
      events: [
        {
          day: 14,
          title: "Design Hackathon Kickoff",
          time: "10:00 AM",
          venue: "Design Lab 3",
          xp: 80,
          category: "Design",
        },
        {
          day: 22,
          title: "RoboCup Trials 2026",
          time: "02:30 PM",
          venue: "Sports Complex",
          xp: 60,
          category: "Tech",
        },
        {
          day: 28,
          title: "Annual Cultural Fest Night",
          time: "06:00 PM",
          venue: "Main Amphitheatre",
          xp: 100,
          category: "Cultural",
        },
      ] as CalendarEvent[],
    },
  },

  // Footer
  footer: {
    brandName: "zest",
    tagline: "Add some zest to your campus life.",
    links: [
      { label: "Privacy Policy", href: "/privacy" },
      { label: "Terms of Service", href: "/terms" },
      { label: "Contact Us", href: "mailto:hello@zestcampus.app" }, // TODO: Replace email
    ],
    madeBy: "Crafted with passion by a student for students worldwide.",
    copyrightYear: 2026,
  },
};

import { Variants, Transition } from "framer-motion";

/**
 * Shared Motion Variants & Transitions for ZEST Landing Page
 * Respects `prefers-reduced-motion` across all components.
 */

// Custom cubic bezier: cubic-bezier(.22, 1, .36, 1)
export const easeOutExpo: [number, number, number, number] = [0.22, 1, 0.36, 1];

// Standard reveal transition
export const standardTransition: Transition = {
  duration: 0.6,
  ease: easeOutExpo,
};

// Section & card reveal
export const revealVariants: Variants = {
  hidden: {
    opacity: 0,
    y: 24,
  },
  visible: {
    opacity: 1,
    y: 0,
    transition: standardTransition,
  },
};

// Container with staggered children
export const staggerContainer: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.05,
    },
  },
};

// Masked word slide-up for headings
export const wordMaskContainer: Variants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.06,
    },
  },
};

export const wordMaskChild: Variants = {
  hidden: {
    y: "110%",
    opacity: 0,
  },
  visible: {
    y: "0%",
    opacity: 1,
    transition: {
      duration: 0.7,
      ease: easeOutExpo,
    },
  },
};

// Simple fade for reduced motion fallback
export const reducedMotionVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { duration: 0.3 },
  },
};

// Pop-in spring for Logo / Mascot badges
export const popSpringVariants: Variants = {
  hidden: { scale: 0.75, opacity: 0 },
  visible: {
    scale: 1,
    opacity: 1,
    transition: {
      type: "spring",
      stiffness: 260,
      damping: 20,
    },
  },
};

// Card hover transform
export const cardHoverTransition: Transition = {
  duration: 0.25,
  ease: easeOutExpo,
};

import { Variants } from "framer-motion";

export const zestTransition = {
  duration: 0.32,
  ease: [0.22, 1, 0.36, 1],
};

export const zestFastTransition = {
  duration: 0.18,
  ease: [0.22, 1, 0.36, 1],
};

export const zestSlowTransition = {
  duration: 0.6,
  ease: [0.22, 1, 0.36, 1],
};

export const revealVariants: Variants = {
  hidden: {
    opacity: 0,
    y: 12,
  },
  visible: {
    opacity: 1,
    y: 0,
    transition: zestTransition,
  },
  exit: {
    opacity: 0,
    y: -8,
    transition: zestFastTransition,
  },
};

export const containerStaggerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05,
      delayChildren: 0.02,
    },
  },
};

export const hoverLiftProps = {
  whileHover: { y: -2, transition: zestFastTransition },
  whileTap: { scale: 0.97, transition: zestFastTransition },
};

export const buttonPressProps = {
  whileTap: { scale: 0.97, transition: zestFastTransition },
};

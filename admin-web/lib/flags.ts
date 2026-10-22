/**
 * ZEST Admin Feature Flags
 * Phase 2 features are kept behind flags and default to OFF (false).
 */
export const flags = {
  // Events
  cancelArchiveEvent: false,
  scheduledPublish: false,
  recurringEvents: false,
  eventTemplates: false,
  coOrganizers: false,

  // Forms
  formConditionalLogic: false,
  formMultiPage: false,
  formAnswerLimits: false,

  // Registrations
  internalNotes: false,
  resendPass: false,

  // Check-in & Gate
  offlineScanQueue: false,
  volunteerRole: false,
  multipleGates: false,

  // Students & Gamification
  manualXpAdjustments: false,
  mergeStudentDuplicates: false,

  // Announcements
  broadcastAnnouncements: false,

  // Security & Audit
  auditLogViewer: false,
  requireMfaForSuperAdmin: false,
} as const;

export type FeatureFlagKey = keyof typeof flags;

export function isFeatureEnabled(flag: FeatureFlagKey): boolean {
  return flags[flag] ?? false;
}

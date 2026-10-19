import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/shared_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// WIDGET GALLERY SCREEN (/dev/gallery)
/// Interactive showcase of all new shared ZEST UI components, tokens, and animations.
/// ─────────────────────────────────────────────────────────────────────────────

class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  int _selectedChipIndex = 0;
  int _toggleIndex = 0;
  int _navIndex = 0;
  bool _buttonLoading = false;
  bool _buttonSuccess = false;
  final TextEditingController _textController = TextEditingController();
  String? _inputError;

  final List<String> _chipLabels = [
    'All Events',
    'Tech',
    'Cultural',
    'Sports',
    'Workshops',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: ZestTokens.title,
            children: [
              const TextSpan(text: 'Widget '),
              TextSpan(
                text: 'Gallery',
                style: ZestTokens.accentItalic.copyWith(fontSize: 26),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              ZestSnack.info(context, 'ZEST Designjoy System v2.0');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              // 1. ZEST BLOB LOGO
              const ZestSectionHeader(title: 'Brand Vector Logo', accentWord: 'Logo'),
              ZestCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        ZestBlobLogo(size: 32),
                        ZestBlobLogo(size: 48),
                        ZestBlobLogo(size: 72),
                        ZestBlobLogo(size: 96, animateOnLoad: true),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pure CustomPainter squircle vector with dual-layer gaussian glow',
                      textAlign: TextAlign.center,
                      style: ZestTokens.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. ZEST MASCOT
              const ZestSectionHeader(title: 'Living Mascot Moods', accentWord: 'Moods'),
              ZestCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMascotTile('Idle', MascotMood.idle, MascotTint.blue),
                        _buildMascotTile('Happy', MascotMood.happy, MascotTint.lemon),
                        _buildMascotTile('Sleepy', MascotMood.sleepy, MascotTint.lavender),
                        _buildMascotTile('Celebrate', MascotMood.celebrate, MascotTint.mint),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tap mascots to squish. Eyes blink randomly every 3–5 seconds.',
                      textAlign: TextAlign.center,
                      style: ZestTokens.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. BUTTONS
              const ZestSectionHeader(title: 'Button Variants', accentWord: 'Variants'),
              ZestCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ZestButton(
                      text: _buttonSuccess
                          ? 'Pass Claimed!'
                          : _buttonLoading
                              ? 'Processing...'
                              : 'Primary Brand Pill',
                      isLoading: _buttonLoading,
                      isSuccess: _buttonSuccess,
                      icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                      onPressed: () {
                        setState(() => _buttonLoading = true);
                        Future.delayed(const Duration(milliseconds: 1400), () {
                          if (mounted) {
                            setState(() {
                              _buttonLoading = false;
                              _buttonSuccess = true;
                            });
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) setState(() => _buttonSuccess = false);
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ZestButton(
                      text: 'Secondary White Pill',
                      variant: ZestButtonVariant.secondary,
                      onPressed: () {
                        ZestSnack.success(context, 'Secondary button pressed');
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ZestButton(
                            text: 'Ghost Pill',
                            variant: ZestButtonVariant.ghost,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ZestButton(
                            text: 'Danger Pill',
                            variant: ZestButtonVariant.danger,
                            onPressed: () {
                              ZestDialog.show(
                                context,
                                title: 'Confirm Action',
                                message: 'Are you sure you want to test danger dialog?',
                                confirmText: 'Proceed',
                                isDestructive: true,
                                mascotMood: MascotMood.sleepy,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. CHIPS & SEGMENTED TOGGLE
              const ZestSectionHeader(title: 'Filters & Toggles', accentWord: 'Toggles'),
              ZestCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZestSegmentedToggle(
                      options: const ['Upcoming', 'Attended 🏆', 'Saved'],
                      selectedIndex: _toggleIndex,
                      onChanged: (idx) => setState(() => _toggleIndex = idx),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_chipLabels.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ZestChip(
                              label: _chipLabels[i],
                              isSelected: _selectedChipIndex == i,
                              onTap: () => setState(() => _selectedChipIndex = i),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. TEXT FIELDS
              const ZestSectionHeader(title: 'Clean Text Fields', accentWord: 'Fields'),
              ZestCard(
                child: Column(
                  children: [
                    ZestTextField(
                      controller: _textController,
                      label: 'College Roll Number',
                      hintText: 'e.g. 22BCS1048',
                      prefixIcon: const Icon(Icons.badge_outlined, color: ZestTokens.ink3, size: 20),
                      errorText: _inputError,
                      onChanged: (v) {
                        if (_inputError != null) setState(() => _inputError = null);
                      },
                    ),
                    const SizedBox(height: 14),
                    const ZestTextField(
                      label: 'Campus Password',
                      hintText: '••••••••',
                      isPassword: true,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: ZestTokens.ink3, size: 20),
                    ),
                    const SizedBox(height: 14),
                    ZestButton(
                      text: 'Trigger Error Shake',
                      variant: ZestButtonVariant.secondary,
                      height: 42,
                      onPressed: () {
                        setState(() {
                          _inputError = 'Invalid roll number format';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. PROGRESS, COUNTERS & STATUS PILLS
              const ZestSectionHeader(title: 'Indicators & Numbers', accentWord: 'Numbers'),
              ZestCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Campus XP Progress', style: ZestTokens.bodyBold),
                        const CountUpText(
                          value: 1420,
                          suffix: ' XP',
                          style: TextStyle(
                            color: ZestTokens.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const ZestProgressBar(value: 0.71),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        StatusPill(label: 'Verified ✓', type: ZestStatusType.verified),
                        StatusPill(label: 'Pending...', type: ZestStatusType.pending),
                        StatusPill(label: 'Rejected ✕', type: ZestStatusType.rejected),
                        StatusPill(label: 'Attended ✓', type: ZestStatusType.attended),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7. AVATAR & SKELETON
              const ZestSectionHeader(title: 'Avatar & Skeletons', accentWord: 'Skeletons'),
              ZestCard(
                child: Row(
                  children: [
                    const ZestAvatar(
                      name: 'Aarav Sharma',
                      radius: 30,
                      hasGradientRing: true,
                      isEditable: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ZestSkeleton.text(width: 140, height: 16),
                          SizedBox(height: 8),
                          ZestSkeleton.text(width: 90, height: 12),
                          SizedBox(height: 8),
                          ZestSkeleton(width: double.infinity, height: 6, radius: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 8. MODAL TRIGGERS
              const ZestSectionHeader(title: 'Modals & Toasts', accentWord: 'Toasts'),
              ZestCard(
                child: Row(
                  children: [
                    Expanded(
                      child: ZestButton(
                        text: 'Top Toast',
                        variant: ZestButtonVariant.secondary,
                        height: 44,
                        onPressed: () {
                          ZestSnack.success(
                            context,
                            'Pass verified at Main Gate! +80 XP awarded.',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ZestButton(
                        text: 'Bottom Sheet',
                        variant: ZestButtonVariant.secondary,
                        height: 44,
                        onPressed: () {
                          ZestBottomSheet.show(
                            context: context,
                            title: 'Campus Filters',
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ZestEmptyState(
                                    title: 'All filters clear',
                                    subtitle: 'Every club and workshop is currently shown.',
                                    mood: MascotMood.happy,
                                    tint: MascotTint.lemon,
                                  ),
                                  const SizedBox(height: 16),
                                  ZestButton(
                                    text: 'Close',
                                    fullWidth: true,
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Pinned ZestFloatingNavBar preview
          ZestFloatingNavBar(
            currentIndex: _navIndex,
            onTap: (idx) => setState(() => _navIndex = idx),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotTile(String label, MascotMood mood, MascotTint tint) {
    return Column(
      children: [
        ZestMascot(
          size: 64,
          mood: mood,
          tint: tint,
          onTap: () {
            ZestSnack.info(context, '$label mascot tapped!');
          },
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: ZestTokens.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

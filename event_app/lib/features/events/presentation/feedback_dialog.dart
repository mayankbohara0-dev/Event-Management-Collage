import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/zest_tokens.dart';
import '../../../shared/widgets/shared_widgets.dart';

class FeedbackDialog extends StatefulWidget {
  final String eventId;
  const FeedbackDialog({super.key, required this.eventId});

  static void show(BuildContext context, String eventId) {
    ZestBottomSheet.show(
      context: context,
      title: 'Rate Experience',
      accentWord: 'event',
      child: FeedbackDialog(eventId: eventId),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ZestSnack.show(
        context,
        message: 'Please select a star rating first! ⭐',
        type: ZestSnackType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('event_feedback').insert({
        'event_id': widget.eventId,
        'student_id': user.id,
        'rating': _rating,
        'review': _reviewController.text.trim(),
      });

      // Award +10 XP to student profile
      try {
        final pRes = await Supabase.instance.client
            .from('student_profiles')
            .select('points')
            .eq('id', user.id)
            .maybeSingle();
        final currentPts = (pRes?['points'] as num?)?.toInt() ?? 0;
        await Supabase.instance.client
            .from('student_profiles')
            .update({'points': currentPts + 10})
            .eq('id', user.id);
      } catch (_) {}

      if (mounted) {
        Navigator.pop(context);
        ZestSnack.show(
          context,
          message: 'Thanks for your review! +10 Zest Points earned 🍋',
          type: ZestSnackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        ZestSnack.show(
          context,
          message: 'You have already submitted feedback for this event.',
          type: ZestSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How was the event? Your review helps future organizers!',
          textAlign: TextAlign.center,
          style: ZestTokens.body.copyWith(
            color: ZestTokens.ink2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = _rating > index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _rating = index + 1);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isSelected ? const Color(0xFFF59E0B) : ZestTokens.line,
                    size: 42,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _reviewController,
          maxLines: 3,
          style: ZestTokens.body.copyWith(color: ZestTokens.ink),
          decoration: InputDecoration(
            hintText: 'What did you love? Any ideas for improvement?',
            hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
            filled: true,
            fillColor: ZestTokens.fill,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: const BorderSide(color: ZestTokens.core, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 22),
        ZestButton(
          text: 'Submit Feedback 🚀',
          variant: ZestButtonVariant.primary,
          isLoading: _isSubmitting,
          fullWidth: true,
          onPressed: _submitFeedback,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

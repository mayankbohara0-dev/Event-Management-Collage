import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';

class FeedbackDialog extends StatefulWidget {
  final String eventId;
  const FeedbackDialog({super.key, required this.eventId});

  static void show(BuildContext context, String eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackDialog(eventId: eventId),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating first! ⭐'),
          backgroundColor: AppColors.error,
        ),
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

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks for your review! +10 Zest Points earned 🍋'),
            backgroundColor: AppColors.lime,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already submitted feedback for this event.'),
            backgroundColor: AppColors.error,
          ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
          border: Border(
            top: BorderSide(color: AppColors.borderDark, width: 1.5),
            left: BorderSide(color: AppColors.borderDark, width: 1.5),
            right: BorderSide(color: AppColors.borderDark, width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate the Experience 🍋',
              style: AppTextStyles.title20.copyWith(color: AppColors.paper),
            ),
            const SizedBox(height: 6),
            Text(
              'How was the event? Your review helps future organizers!',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(color: AppColors.grey400),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final isSelected = _rating > index;
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isSelected ? AppColors.lime : AppColors.borderDark,
                        size: 44,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              style: AppTextStyles.body15.copyWith(color: AppColors.paper),
              decoration: InputDecoration(
                hintText: 'What did you love? Any ideas for improvement?',
                hintStyle: AppTextStyles.body14.copyWith(color: AppColors.grey400),
                filled: true,
                fillColor: AppColors.surfaceCard,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.lime, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            ZestButton(
              label: 'Submit Feedback 🚀',
              variant: ZestButtonVariant.primary,
              isLoading: _isSubmitting,
              onPressed: _submitFeedback,
            ),
          ],
        ),
      ),
    );
  }
}

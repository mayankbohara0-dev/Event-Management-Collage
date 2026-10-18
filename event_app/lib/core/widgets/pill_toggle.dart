import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// PillToggle — a segmented control pill (e.g. "Weekly | Monthly | All-time").
class PillToggle extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.circularPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.charcoal : Colors.transparent,
                borderRadius: AppRadius.circularPill,
              ),
              child: Text(
                options[i],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.grey400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

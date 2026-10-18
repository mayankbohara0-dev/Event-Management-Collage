import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class ZestCategory {
  const ZestCategory({required this.label, required this.icon, this.color});
  final String label;
  final String icon;
  final Color? color;
}

/// Horizontally scrollable category chip row.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<ZestCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const List<Color> _defaultColors = [
    AppColors.coral,
    AppColors.teal,
    AppColors.periwinkle,
    AppColors.mustard,
    AppColors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = i == selectedIndex;
          final color = cat.color ?? _defaultColors[i % _defaultColors.length];
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.grey100,
                borderRadius: AppRadius.circularPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

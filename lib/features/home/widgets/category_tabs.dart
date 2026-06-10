import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // جهت RTL: آیتم‌ها از راست شروع میشن
        reverse: true,
        itemCount: provider.categories.length + 1, // +۱ برای دکمه «همه»
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // اولین آیتم (در RTL آخرین سمت راست) = «همه»
          if (index == provider.categories.length) {
            return _CategoryChip(
               label: 'همه',
  imagePath: 'assets/images/all.png',
              isSelected: provider.selectedCategoryId == null,
              onTap: () => provider.selectCategory(null),
              isDark: isDark,
            );
          }

          final category = provider.categories[index];
          return _CategoryChip(
            label: category.name,
            imagePath: category.imageUrl,
            isSelected: provider.selectedCategoryId == category.id,
            onTap: () => provider.selectCategory(category.id),
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
  imagePath,
  width: 20,
  height: 20,
  fit: BoxFit.contain,
),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkText
                        : AppColors.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryChipSelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryChipSelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => onSelected(cat),
              selectedColor: AppTheme.primary.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              backgroundColor: AppTheme.surfaceVariant,
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

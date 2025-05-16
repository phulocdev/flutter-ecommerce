import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/category.dart';

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category?) onCategorySelected;

  const CategoryTabs({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Mock categories if the list is empty
    final displayCategories = categories.isEmpty ? [
          ]
        : categories;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayCategories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final isSelected = selectedCategory?.id == category.id;

          // Special case for "All" category
          final isAll = category.name == 'All';
          final isAllSelected = isAll && selectedCategory == null;

          return GestureDetector(
            onTap: () {
              onCategorySelected(isAll ? null : category);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isSelected || isAllSelected)
                    ? colorScheme.primary
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isSelected || isAllSelected)
                      ? colorScheme.primary
                      : Colors.grey.withOpacity(0.3),
                ),
                boxShadow: (isSelected || isAllSelected)
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: (isSelected || isAllSelected)
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: (isSelected || isAllSelected)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

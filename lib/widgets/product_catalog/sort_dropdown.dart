import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final String? currentSortOption;
  final Function(String) onSortChanged;

  const SortDropdown({
    Key? key,
    required this.currentSortOption,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: currentSortOption,
        icon: const Icon(Icons.arrow_drop_down),
        underline: const SizedBox(),
        isDense: true,
        borderRadius: BorderRadius.circular(8),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onSortChanged(newValue);
          }
        },
        items: const [
          DropdownMenuItem(
            value: 'name.asc',
            child: Text('Tên sản phẩm (A-Z)'),
          ),
          DropdownMenuItem(
            value: 'name.desc',
            child: Text('Tên sản phẩm (Z-A)'),
          ),
          DropdownMenuItem(
            value: 'basePrice.asc',
            child: Text('Giá (Tăng dần)'),
          ),
          DropdownMenuItem(
            value: 'basePrice.desc',
            child: Text('Giá (Giảm dần)'),
          ),
          DropdownMenuItem(
            value: 'createdAt.desc',
            child: Text('Mới nhất'),
          ),
          DropdownMenuItem(
            value: 'createdAt.asc',
            child: Text('Cũ nhất'),
          ),
          // DropdownMenuItem(
          //   value: 'rating',
          //   child: Text('Highest Rated'),
          // ),
          // DropdownMenuItem(
          //   value: 'newest',
          //   child: Text('Newest First'),
          // ),
        ],
      ),
    );
  }
}

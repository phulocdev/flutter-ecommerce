import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onToggleSearch;
  final ColorScheme colorScheme;

  const HomeAppBar({
    Key? key,
    required this.isSearching,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      title: isSearching
          ? _buildSearchField()
          : Row(
              children: [
                // Image.asset(
                //   'assets/images/logo.png',
                //   height: 32,
                //   // If you don't have this asset, replace with:
                //   // Icon(Icons.shopping_bag, color: colorScheme.primary, size: 32),
                // ),
                const SizedBox(width: 8),
                Text(
                  'Flutter Ecommerce',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
            color: colorScheme.primary,
          ),
          onPressed: onToggleSearch,
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.primary,
          ),
          onPressed: () {
            // Navigate to notifications
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          height: 1.0,
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm sản phẩm...',
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

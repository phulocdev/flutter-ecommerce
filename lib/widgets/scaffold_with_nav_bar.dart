// lib/widgets/scaffold_with_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  // Use ConsumerWidget if reading providers
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optional: Watch cart provider for badge count
    final cartItemCount =
        ref.watch(cartProvider).length; // Use your specific provider

    return Scaffold(
      // The body will be filled by the navigationShell
      body: navigationShell,

      // The BottomNavigationBar remains constant
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              // Add badge here
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              // Also on active icon
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Giỏ hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tôi',
          ),
        ],
        currentIndex:
            navigationShell.currentIndex, // Use index from navigationShell
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true, // Keep labels visible
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onTap(context, index), // Handle tap using goBranch
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating between tabs, use the navigationShell's goBranch method,
    // which preserves state of each tab's navigator stack.
    navigationShell.goBranch(
      index,
      // Navigate to the initial location when tapping the item that is already active
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

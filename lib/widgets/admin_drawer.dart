import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final int? selectedIndex;
  final Function(int) onItemTapped;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.indigo),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(
            context,
            index: 0,
            icon: Icons.dashboard,
            title: 'Dashboard',
          ),
          _buildListTile(
            context,
            index: 1,
            icon: Icons.people,
            title: 'User Management',
          ),
          _buildListTile(
            context,
            index: 2,
            icon: Icons.shopping_bag,
            title: 'Product Management',
          ),
          _buildListTile(
            context,
            index: 3,
            icon: Icons.receipt,
            title: 'Order Management',
          ),
          _buildListTile(
            context,
            index: 4,
            icon: Icons.discount,
            title: 'Coupon Management',
          ),
          _buildListTile(
            context,
            index: 5,
            icon: Icons.support_agent,
            title: 'Customer Support',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Add logout functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      selectedTileColor: Colors.indigo.withOpacity(0.1),
      onTap: () {
        onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}

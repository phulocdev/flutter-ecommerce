import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Welcome
            _buildWelcomeHeader(),
            const SizedBox(height: 20),

            // Stats Cards Row
            _buildStatsCards(context),
            const SizedBox(height: 20),

            // Recent Activity
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào Admin!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đây là bảng điều khiển quản trị hệ thống',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Tổng người dùng',
          value: '1,024',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Đơn hàng hôm nay',
          value: '56',
          icon: Icons.shopping_cart,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Doanh thu',
          value: '\$12,345',
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Tỷ lệ phản hồi',
          value: '85%',
          icon: Icons.feedback,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildActivityItem(
                'Người dùng mới: Nguyễn Văn A', Icons.person_add),
            _buildActivityItem('Đơn hàng #1234 đã thanh toán', Icons.payment),
            _buildActivityItem('Sản phẩm mới được thêm', Icons.add_box),
            _buildActivityItem('Phiếu giảm giá đã tạo', Icons.discount),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.indigo),
      title: Text(text),
      trailing:
          const Text('10 phút trước', style: TextStyle(color: Colors.grey)),
    );
  }
}

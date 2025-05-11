import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/data/dummy_products.dart';

class SimpleDashboardView extends StatelessWidget {
  const SimpleDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> topSellingProducts = bestSellers.take(5).toList();

    // Dữ liệu mẫu cho biểu đồ
    final List<FlSpot> chartData = [
      const FlSpot(0, 500),
      const FlSpot(1, 800),
      const FlSpot(2, 600),
      const FlSpot(3, 900),
      const FlSpot(4, 700),
      const FlSpot(5, 1000),
      const FlSpot(6, 850),
      const FlSpot(7, 950),
      const FlSpot(8, 1100),
      const FlSpot(9, 1200),
      const FlSpot(10, 1000),
      const FlSpot(11, 1300),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tổng quan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              _buildInfoCard(
                  context, 'Tổng số người dùng', '10,000', Icons.people),
              const SizedBox(width: 16),
              _buildInfoCard(
                  context, 'Số người dùng mới', '1,000', Icons.person_add),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              _buildInfoCard(
                  context, 'Số đơn hàng', '5,000', Icons.shopping_cart),
              const SizedBox(width: 16),
              _buildInfoCard(
                  context, 'Doanh thu', '\$1,000,000', Icons.attach_money),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Sản phẩm bán chạy nhất',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: topSellingProducts.length,
            itemBuilder: (context, index) {
              final product = topSellingProducts[index];
              return _buildProductGridItem(context, product);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Biểu đồ số lượng sản phẩm bán ra theo thời gian',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  // Cấu hình các thuộc tính của biểu đồ
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Thay đổi logic lấy tiêu đề trục dưới
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Jan');
                            case 1:
                              return const Text('Feb');
                            case 2:
                              return const Text('Mar');
                            case 3:
                              return const Text('Apr');
                            case 4:
                              return const Text('May');
                            case 5:
                              return const Text('Jun');
                            case 6:
                              return const Text('Jul');
                            case 7:
                              return const Text('Aug');
                            case 8:
                              return const Text('Sep');
                            case 9:
                              return const Text('Oct');
                            case 10:
                              return const Text('Nov');
                            case 11:
                              return const Text('Dec');
                            default:
                              return const Text('');
                          }
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Định dạng giá trị trục tung là số nguyên
                          return Text(value.toInt().toString());
                        },
                        reservedSize: 30,
                        interval: 200, // Khoảng cách giữa các giá trị trên trục tung
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)), 
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)), 
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  // Dữ liệu đường thẳng của biểu đồ
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff23b6e6),
                          Color(0xff02d39a),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0x3323b6e6),
                            const Color(0x3302d39a),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo một Card hiển thị thông tin
  Widget _buildInfoCard(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tạo một ô sản phẩm trong GridView
  Widget _buildProductGridItem(BuildContext context, Product product) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}


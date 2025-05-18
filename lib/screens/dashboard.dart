import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeInterval = 'Năm';

  final List<FlSpot> _revenueData = [
    const FlSpot(0, 3),
    const FlSpot(1, 2),
    const FlSpot(2, 5),
    const FlSpot(3, 3.5),
    const FlSpot(4, 4.5),
    const FlSpot(5, 6),
    const FlSpot(6, 6.5),
    const FlSpot(7, 6),
  ];
  final List<FlSpot> _profitData = [
    const FlSpot(0, 1),
    const FlSpot(1, 1.5),
    const FlSpot(2, 2),
    const FlSpot(3, 2.5),
    const FlSpot(4, 3),
    const FlSpot(5, 4),
    const FlSpot(6, 4.5),
    const FlSpot(7, 4),
  ];

  final List<BarChartGroupData> _bestSellingProductData = [
    BarChartGroupData(
        x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
    BarChartGroupData(
        x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.green)]),
    BarChartGroupData(
        x: 2, barRods: [BarChartRodData(toY: 6, color: Colors.orange)]),
    BarChartGroupData(
        x: 3, barRods: [BarChartRodData(toY: 9, color: Colors.purple)]),
    BarChartGroupData(
        x: 4, barRods: [BarChartRodData(toY: 7, color: Colors.red)]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar for Simple vs Advanced Dashboard
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard Tổng quan'),
            Tab(text: 'Dashboard Nâng cao'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
        // Tab Bar View to display content based on selected tab
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSimpleDashboard(),
              _buildAdvancedDashboard(),
            ],
          ),
        ),
      ],
    );
  }

  // --- Simple Dashboard Content ---
  Widget _buildSimpleDashboard() {
    return SingleChildScrollView(
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

          // Best Selling Products Chart and Recent Activity side by side on larger screens
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Sản phẩm bán chạy nhất'),
                          const SizedBox(height: 10),
                          _buildBestSellingProductsChart(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildRecentActivitySection(),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Sản phẩm bán chạy nhất'),
                    const SizedBox(height: 10),
                    _buildBestSellingProductsChart(),
                    const SizedBox(height: 20),
                    _buildRecentActivitySection(),
                  ],
                );
              }
            },
          ),
        ],
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
    // Adjust the number of cards per row based on screen width
    int crossAxisCount = 2;
    double width = MediaQuery.of(context).size.width;

    if (width > 600) crossAxisCount = 3;
    if (width > 900) crossAxisCount = 4;
    if (width > 1200) crossAxisCount = 6;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
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
          title: 'Người dùng mới',
          value: '56',
          icon: Icons.person_add,
          color: Colors.cyan,
        ),
        _buildStatCard(
          title: 'Tổng đơn hàng',
          value: '1,500',
          icon: Icons.shopping_cart,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Tổng doanh thu',
          value: '\$120,345',
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Tổng sản phẩm',
          value: '500',
          icon: Icons.inventory_2,
          color: Colors.red,
        ),
        _buildStatCard(
          title: 'Đơn hàng hôm nay',
          value: '35',
          icon: Icons.receipt,
          color: Colors.teal,
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

  Widget _buildBestSellingProductsChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: _bestSellingProductData,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const productNames = [
                        'SP A',
                        'SP B',
                        'SP C',
                        'SP D',
                        'SP E'
                      ];
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(productNames[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
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
            _buildActivityItem('Người dùng mới: Nguyễn Văn A', Icons.person_add,
                '10 phút trước'),
            _buildActivityItem(
                'Đơn hàng #1234 đã thanh toán', Icons.payment, '30 phút trước'),
            _buildActivityItem('Sản phẩm "RAM DDR4 16GB" được thêm',
                Icons.add_box, '1 giờ trước'),
            _buildActivityItem('Phiếu giảm giá "SALE30" đã tạo', Icons.discount,
                '2 giờ trước'),
            _buildActivityItem('Đơn hàng #1235 đang xử lý',
                Icons.pending_actions, '3 giờ trước'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text, IconData icon, String timeAgo) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.indigo),
      title: Text(text),
      trailing: Text(timeAgo, style: const TextStyle(color: Colors.grey)),
    );
  }

  // --- Advanced Dashboard Content ---
  Widget _buildAdvancedDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Chọn khoảng thời gian'),
          const SizedBox(height: 10),
          _buildTimeIntervalSelector(),
          const SizedBox(height: 20),

          _buildSectionTitle('Thống kê theo khoảng thời gian'),
          const SizedBox(height: 10),
          _buildIntervalMetrics(),
          const SizedBox(height: 20),

          // Responsive grid layout for charts
          LayoutBuilder(
            builder: (context, constraints) {
              // Determine how many charts to show per row based on screen width
              if (constraints.maxWidth > 1200) {
                // Large screens: 3 charts per row
                return Column(
                  children: [
                    // First row of charts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Doanh thu theo thời gian'),
                              const SizedBox(height: 10),
                              _buildRevenueTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Lợi nhuận theo thời gian'),
                              const SizedBox(height: 10),
                              _buildProfitTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Đơn hàng theo thời gian'),
                              const SizedBox(height: 10),
                              _buildOrderTrendChart(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Second row of charts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Số lượng sản phẩm bán ra'),
                              const SizedBox(height: 10),
                              _buildProductCountTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Loại sản phẩm bán ra'),
                              const SizedBox(height: 10),
                              _buildProductTypeTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('So sánh doanh thu'),
                              const SizedBox(height: 10),
                              _buildComparativeRevenueChart(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Third row - Profit comparison chart
                    _buildSectionTitle(
                        'So sánh lợi nhuận (Năm trước vs Năm hiện tại)'),
                    const SizedBox(height: 10),
                    _buildComparativeProfitChart(),
                  ],
                );
              } else if (constraints.maxWidth > 800) {
                // Medium screens: 2 charts per row
                return Column(
                  children: [
                    // First row of charts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Doanh thu theo thời gian'),
                              const SizedBox(height: 10),
                              _buildRevenueTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Lợi nhuận theo thời gian'),
                              const SizedBox(height: 10),
                              _buildProfitTrendChart(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Second row of charts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Đơn hàng theo thời gian'),
                              const SizedBox(height: 10),
                              _buildOrderTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Số lượng sản phẩm bán ra'),
                              const SizedBox(height: 10),
                              _buildProductCountTrendChart(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Third row of charts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Loại sản phẩm bán ra'),
                              const SizedBox(height: 10),
                              _buildProductTypeTrendChart(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('So sánh doanh thu'),
                              const SizedBox(height: 10),
                              _buildComparativeRevenueChart(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Fourth row - Profit comparison chart
                    _buildSectionTitle(
                        'So sánh lợi nhuận (Năm trước vs Năm hiện tại)'),
                    const SizedBox(height: 10),
                    _buildComparativeProfitChart(),
                  ],
                );
              } else {
                // Small screens: 1 chart per row (original layout)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Biểu đồ Doanh thu theo thời gian'),
                    const SizedBox(height: 10),
                    _buildRevenueTrendChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Biểu đồ Lợi nhuận theo thời gian'),
                    const SizedBox(height: 10),
                    _buildProfitTrendChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Biểu đồ Đơn hàng theo thời gian'),
                    const SizedBox(height: 10),
                    _buildOrderTrendChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        'Biểu đồ Số lượng sản phẩm bán ra theo thời gian'),
                    const SizedBox(height: 10),
                    _buildProductCountTrendChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        'Biểu đồ Loại sản phẩm bán ra theo thời gian'),
                    const SizedBox(height: 10),
                    _buildProductTypeTrendChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        'So sánh Doanh thu (Năm trước vs Năm hiện tại)'),
                    const SizedBox(height: 10),
                    _buildComparativeRevenueChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        'So sánh Lợi nhuận (Năm trước vs Năm hiện tại)'),
                    const SizedBox(height: 10),
                    _buildComparativeProfitChart(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTimeIntervalSelector() {
    final List<String> intervals = ['Năm', 'Quý', 'Tháng', 'Tuần', 'Tùy chỉnh'];
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedTimeInterval,
            items: intervals.map((String interval) {
              return DropdownMenuItem<String>(
                value: interval,
                child: Text(interval),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTimeInterval = newValue;
                });
                if (newValue == 'Tùy chỉnh') {
                  _selectDateRange(context);
                }
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            ),
          ),
        ),
        if (_selectedTimeInterval == 'Tùy chỉnh') ...[
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              _selectDateRange(context);
            },
            child: const Text('Chọn ngày'),
          ),
        ]
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      // Handle the selected date range
      print('Khoảng ngày đã chọn: ${picked.start} đến ${picked.end}');
    }
  }

  Widget _buildIntervalMetrics() {
    // Display key metrics for the selected time interval
    String ordersSold = '500';
    String totalRevenue = '\$50,000';
    String overallProfit = '\$15,000';

    // Adjust placeholder text based on selected interval
    String intervalText = 'trong $_selectedTimeInterval';
    if (_selectedTimeInterval == 'Tùy chỉnh') {
      intervalText = 'trong khoảng đã chọn';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // For larger screens, show metrics in a row
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem(
                    'Tổng số đơn hàng đã bán $intervalText:',
                    ordersSold,
                    Colors.green,
                  ),
                  _buildMetricItem(
                    'Tổng doanh thu $intervalText:',
                    totalRevenue,
                    Colors.blue,
                  ),
                  _buildMetricItem(
                    'Tổng lợi nhuận $intervalText:',
                    overallProfit,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          );
        } else {
          // For smaller screens, show metrics in a column
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng số đơn hàng đã bán $intervalText:',
                      style: const TextStyle(fontSize: 16)),
                  Text(ordersSold,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 10),
                  Text('Tổng doanh thu $intervalText:',
                      style: const TextStyle(fontSize: 16)),
                  Text(totalRevenue,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  const SizedBox(height: 10),
                  Text('Tổng lợi nhuận $intervalText:',
                      style: const TextStyle(fontSize: 16)),
                  Text(overallProfit,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple)),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Optimized chart widgets with reduced height for better fit in grid layout
  Widget _buildRevenueTrendChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'T1',
                        'T2',
                        'T3',
                        'T4',
                        'T5',
                        'T6',
                        'T7',
                        'T8'
                      ];
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(months[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots: _revenueData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfitTrendChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const intervals = [
                        'Q1',
                        'Q2',
                        'Q3',
                        'Q4',
                        'Q1',
                        'Q2',
                        'Q3',
                        'Q4'
                      ];
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(intervals[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots: _profitData,
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTrendChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: List.generate(
                  8,
                  (i) => BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: i * 10 + 20, color: Colors.green)
                      ])),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const periods = [
                        'P1',
                        'P2',
                        'P3',
                        'P4',
                        'P5',
                        'P6',
                        'P7',
                        'P8'
                      ];
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(periods[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCountTrendChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const periods = [
                        'W1',
                        'W2',
                        'W3',
                        'W4',
                        'W5',
                        'W6',
                        'W7',
                        'W8'
                      ];
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(periods[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      List.generate(8, (i) => FlSpot(i.toDouble(), i * 5 + 10)),
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductTypeTrendChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                    value: 30, title: 'CPU', color: Colors.blue),
                PieChartSectionData(
                    value: 25, title: 'GPU', color: Colors.green),
                PieChartSectionData(
                    value: 20, title: 'RAM', color: Colors.orange),
                PieChartSectionData(value: 15, title: 'SSD', color: Colors.red),
                PieChartSectionData(
                    value: 10, title: 'Khác', color: Colors.purple),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparativeRevenueChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'T1',
                        'T2',
                        'T3',
                        'T4',
                        'T5',
                        'T6',
                        'T7',
                        'T8',
                        'T9',
                        'T10',
                        'T11',
                        'T12'
                      ];
                      if (value.toInt() < 0 || value.toInt() >= months.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(months[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              lineBarsData: [
                // Data for Current Year
                LineChartBarData(
                  spots: [
                    FlSpot(0, 4),
                    FlSpot(1, 3.5),
                    FlSpot(2, 5),
                    FlSpot(3, 4.5),
                    FlSpot(4, 5.5),
                    FlSpot(5, 7),
                    FlSpot(6, 7.5)
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
                // Data for Previous Year
                LineChartBarData(
                  spots: [
                    FlSpot(0, 3),
                    FlSpot(1, 3),
                    FlSpot(2, 4),
                    FlSpot(3, 4),
                    FlSpot(4, 5),
                    FlSpot(5, 6),
                    FlSpot(6, 6.5)
                  ],
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparativeProfitChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 2.5, // Wider aspect ratio for better visibility
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'T1',
                        'T2',
                        'T3',
                        'T4',
                        'T5',
                        'T6',
                        'T7',
                        'T8',
                        'T9',
                        'T10',
                        'T11',
                        'T12'
                      ];
                      if (value.toInt() < 0 || value.toInt() >= months.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: Text(months[value.toInt()],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              lineBarsData: [
                // Data for Current Year Profit
                LineChartBarData(
                  spots: [
                    FlSpot(0, 1.5),
                    FlSpot(1, 1),
                    FlSpot(2, 2),
                    FlSpot(3, 1.8),
                    FlSpot(4, 2.5),
                    FlSpot(5, 3),
                    FlSpot(6, 3.2)
                  ],
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
                // Data for Previous Year Profit
                LineChartBarData(
                  spots: [
                    FlSpot(0, 1),
                    FlSpot(1, 1.2),
                    FlSpot(2, 1.5),
                    FlSpot(3, 1.7),
                    FlSpot(4, 2),
                    FlSpot(5, 2.5),
                    FlSpot(6, 2.8)
                  ],
                  isCurved: true,
                  color: Colors.deepOrange,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

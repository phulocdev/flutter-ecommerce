import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdvancedDashboardView extends StatefulWidget {
  const AdvancedDashboardView({Key? key}) : super(key: key);

  @override
  _AdvancedDashboardViewState createState() => _AdvancedDashboardViewState();
}

class _AdvancedDashboardViewState extends State<AdvancedDashboardView> {
  String _selectedTimeFrame = 'Năm';
  DateTime? _startDate;
  DateTime? _endDate;

  List<FlSpot> _revenueData = [
    const FlSpot(0, 500),
    const FlSpot(1, 800),
    const FlSpot(2, 600),
    const FlSpot(3, 900),
    const FlSpot(4, 700),
    const FlSpot(5, 1000),
    const FlSpot(6, 850),
  ];
  List<FlSpot> _profitData = [
    const FlSpot(0, 300),
    const FlSpot(1, 400),
    const FlSpot(2, 250),
    const FlSpot(3, 500),
    const FlSpot(4, 350),
    const FlSpot(5, 600),
    const FlSpot(6, 450),
  ];

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Dashboard Nâng Cao',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTimeFrameSelector(),
          const SizedBox(height: 20),
          _buildDateRangeSelector(context),
          const SizedBox(height: 20),
          _buildSummary(),
          const SizedBox(height: 20),
          _buildRevenueChart(),
          const SizedBox(height: 20),
          _buildProfitChart(),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Row(
      children: [
        const Text('Chọn khoảng thời gian: '),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedTimeFrame,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimeFrame = newValue;
                _updateChartData();
              });
            }
          },
          items: <String>['Năm', 'Quý', 'Tháng', 'Tuần', 'Tùy chỉnh']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Row(
      children: [
        const Text('Chọn ngày: '),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => _selectDate(context, true),
          child: Text(_startDate == null
              ? 'Ngày bắt đầu'
              : DateFormat('dd/MM/yyyy').format(_startDate!),
              style: const TextStyle(fontSize: 14)),
        ),
        const Text(' - '),
        TextButton(
          onPressed: () => _selectDate(context, false),
          child: Text(_endDate == null
              ? 'Ngày kết thúc'
              : DateFormat('dd/MM/yyyy').format(_endDate!),
              style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _updateChartData();
      });
    }
  }

  Widget _buildSummary() {
    int totalOrders = 5500;
    double totalRevenue = 1500000000;
    double totalProfit = 700000000;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Số liệu tổng quan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Số đơn hàng: $totalOrders'),
            Text('Tổng doanh thu: ${_currencyFormat.format(totalRevenue)}'),
            Text('Tổng lợi nhuận: ${_currencyFormat.format(totalProfit)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu đồ doanh thu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.8,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                      left: BorderSide(color: Colors.black, width: 1),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1, 
                        getTitlesWidget:
                            (double value, TitleMeta meta) {
                          return _getBottomTitle(value);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (double value, TitleMeta meta) {
                          return _getLeftTitle(value);
                        },
                        reservedSize: 35,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _revenueData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu đồ lợi nhuận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.8,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                      left: BorderSide(color: Colors.black, width: 1),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1, 
                        getTitlesWidget:
                            (double value, TitleMeta meta) {
                          return _getBottomTitle(value);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (double value, TitleMeta meta) {
                          return _getLeftTitle(value);
                        },
                        reservedSize: 35,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _profitData,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateChartData() {
    List<FlSpot> defaultRevenueData = [
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
    List<FlSpot> defaultProfitData = [
      const FlSpot(0, 300),
      const FlSpot(1, 400),
      const FlSpot(2, 250),
      const FlSpot(3, 500),
      const FlSpot(4, 350),
      const FlSpot(5, 600),
      const FlSpot(6, 450),
      const FlSpot(7, 550),
      const FlSpot(8, 650),
      const FlSpot(9, 750),
      const FlSpot(10, 600),
      const FlSpot(11, 800),
    ];

    if (_selectedTimeFrame == 'Năm') {
      _revenueData = defaultRevenueData;
      _profitData = defaultProfitData;
    } else if (_selectedTimeFrame == 'Quý') {
      _revenueData = [
        const FlSpot(0, 2000),
        const FlSpot(1, 2500),
        const FlSpot(2, 3000),
        const FlSpot(3, 3500),
      ];
      _profitData = [
        const FlSpot(0, 1200),
        const FlSpot(1, 1500),
        const FlSpot(2, 1800),
        const FlSpot(3, 2100),
      ];
    } else if (_selectedTimeFrame == 'Tháng') {
      _revenueData =
          List.generate(30, (index) => FlSpot(index.toDouble(), (index + 1) * 30));
      _profitData =
          List.generate(30, (index) => FlSpot(index.toDouble(), (index + 1) * 15));
    } else if (_selectedTimeFrame == 'Tuần') {
      _revenueData =
          List.generate(7, (index) => FlSpot(index.toDouble(), (index + 1) * 80));
      _profitData =
          List.generate(7, (index) => FlSpot(index.toDouble(), (index + 1) * 40));
    } else if (_selectedTimeFrame == 'Tùy chỉnh') {
      if (_startDate != null && _endDate != null) {
        _revenueData = _getRevenueDataForCustomRange(_startDate!, _endDate!);
        _profitData = _getProfitDataForCustomRange(_startDate!, _endDate!);
      } else {
        _revenueData = defaultRevenueData;
        _profitData = defaultProfitData;
      }
    }

    setState(() {});
  }

  List<FlSpot> _getRevenueDataForCustomRange(DateTime start, DateTime end) {
    List<FlSpot> data = [];
    int days = end.difference(start).inDays;
    for (int i = 0; i <= days; i++) {
      data.add(FlSpot(i.toDouble(), 100 + i * 20));
    }
    return data;
  }

  List<FlSpot> _getProfitDataForCustomRange(DateTime start, DateTime end) {
    List<FlSpot> data = [];
    int days = end.difference(start).inDays;
    for (int i = 0; i <= days; i++) {
      data.add(FlSpot(i.toDouble(), 50 + i * 10));
    }
    return data;
  }

  Widget _getBottomTitle(double value) {
    String titleText = '';
    if (_selectedTimeFrame == 'Năm') {
      switch (value.toInt()) {
        case 0:
          titleText = 'Jan';
          break;
        case 1:
          titleText = 'Feb';
          break;
        case 2:
          titleText = 'Mar';
          break;
        case 3:
          titleText = 'Apr';
          break;
        case 4:
          titleText = 'May';
          break;
        case 5:
          titleText = 'Jun';
          break;
        case 6:
          titleText = 'Jul';
          break;
        case 7:
          titleText = 'Aug';
          break;
        case 8:
          titleText = 'Sep';
          break;
        case 9:
          titleText = 'Oct';
          break;
        case 10:
          titleText = 'Nov';
          break;
        case 11:
          titleText = 'Dec';
          break;
        default:
          titleText = '';
          break;
      }
    } else if (_selectedTimeFrame == 'Quý') {
      switch (value.toInt()) {
        case 0:
          titleText = 'Q1';
          break;
        case 1:
          titleText = 'Q2';
          break;
        case 2:
          titleText = 'Q3';
          break;
        case 3:
          titleText = 'Q4';
          break;
        default:
          titleText = '';
          break;
      }
    } else if (_selectedTimeFrame == 'Tháng') {
      titleText = '${value.toInt() + 1}';
    } else if (_selectedTimeFrame == 'Tuần') {
      switch (value.toInt()) {
        case 0:
          titleText = 'Mon';
          break;
        case 1:
          titleText = 'Tue';
          break;
        case 2:
          titleText = 'Wed';
          break;
        case 3:
          titleText = 'Thu';
          break;
        case 4:
          titleText = 'Fri';
          break;
        case 5:
          titleText = 'Sat';
          break;
        case 6:
          titleText = 'Sun';
          break;
        default:
          titleText = '';
          break;
      }
    } else {
      titleText = DateFormat('dd/MM').format(_startDate!.add(Duration(days: value.toInt())));
    }
    return Text(titleText);
  }

  Widget _getLeftTitle(double value) {
    String titleText = '';
    if (_selectedTimeFrame == 'Năm' ||
        _selectedTimeFrame == 'Tuần' ||
        _selectedTimeFrame == 'Tháng') {
      if (value == 0 ||
          value == 100 ||
          value == 200 ||
          value == 300 ||
          value == 400 ||
          value == 500 ||
          value == 600 ||
          value == 700 ||
          value == 800 ||
          value == 900 ||
          value == 1000 ||
          value == 1100 ||
          value == 1200 ||
          value == 1300) {
        titleText = value.toInt().toString();
      } else {
        titleText = '';
      }
    } else if (_selectedTimeFrame == 'Quý') {
      if (value == 0 ||
          value == 200 ||
          value == 400 ||
          value == 600 ||
          value == 800 ||
          value == 1000 ||
          value == 1200 ||
          value == 1400 ||
          value == 1600 ||
          value == 1800 ||
          value == 2000 ||
          value == 2200 ||
          value == 2400 ||
          value == 2600 ||
          value == 2800 ||
          value == 3000 ||
          value == 3200 ||
          value == 3400 ||
          value == 3600) {
        titleText = value.toInt().toString();
      } else {
        titleText = '';
      }
    } else {
      titleText = _currencyFormat.format(value);
    }
    return Text(titleText);
  }
}

import 'package:flutter/material.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to orders page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 0,
                headingRowColor: MaterialStateProperty.all(
                  colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                headingTextStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                ],
                rows: [
                  _buildOrderRow(
                    '#ORD-001',
                    'John Doe',
                    '2023-05-10',
                    '\$156.00',
                    'Delivered',
                    Colors.green,
                  ),
                  _buildOrderRow(
                    '#ORD-002',
                    'Jane Smith',
                    '2023-05-09',
                    '\$243.50',
                    'Processing',
                    Colors.blue,
                  ),
                  _buildOrderRow(
                    '#ORD-003',
                    'Robert Johnson',
                    '2023-05-08',
                    '\$89.99',
                    'Delivered',
                    Colors.green,
                  ),
                  _buildOrderRow(
                    '#ORD-004',
                    'Emily Davis',
                    '2023-05-07',
                    '\$321.75',
                    'Cancelled',
                    Colors.red,
                  ),
                  _buildOrderRow(
                    '#ORD-005',
                    'Michael Wilson',
                    '2023-05-06',
                    '\$175.25',
                    'Processing',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildOrderRow(
    String orderId,
    String customer,
    String date,
    String amount,
    String status,
    Color statusColor,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(
          orderId,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(Text(customer)),
        DataCell(Text(date)),
        DataCell(Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

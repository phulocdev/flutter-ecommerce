import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double height;
  final List<Widget>? actions;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    required this.height,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
            SizedBox(
              height: height,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TopProductsList extends StatelessWidget {
  const TopProductsList({super.key});

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
                const Text(
                  'Top Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to products page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProductItem(
              'Smartphone X Pro',
              'Electronics',
              '\$999.99',
              '324 sold',
              'https://picsum.photos/id/1/60/60',
            ),
            const Divider(),
            _buildProductItem(
              'Wireless Headphones',
              'Audio',
              '\$199.99',
              '287 sold',
              'https://picsum.photos/id/2/60/60',
            ),
            const Divider(),
            _buildProductItem(
              'Smart Watch Series 5',
              'Wearables',
              '\$349.99',
              '245 sold',
              'https://picsum.photos/id/3/60/60',
            ),
            const Divider(),
            _buildProductItem(
              'Laptop Pro 16"',
              'Computers',
              '\$1,899.99',
              '198 sold',
              'https://picsum.photos/id/4/60/60',
            ),
            const Divider(),
            _buildProductItem(
              'Wireless Earbuds',
              'Audio',
              '\$129.99',
              '176 sold',
              'https://picsum.photos/id/5/60/60',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    String name,
    String category,
    String price,
    String sold,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sold,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

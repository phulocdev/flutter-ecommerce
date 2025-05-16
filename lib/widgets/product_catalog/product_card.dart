import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go(
            '${AppRoute.productCatalog.path}/${product.id}',
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
            ),

            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Text(
                      product.brand?.name ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Product name
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < 4.5
                                ? Icons.star
                                : index < 4.5
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                          // return Icon(
                          //   index < product.rating.floor()
                          //       ? Icons.star
                          //       : index < product.rating
                          //           ? Icons.star_half
                          //           : Icons.star_border,
                          //   color: Colors.amber,
                          //   size: 16,
                          // );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          4.5.toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                        // Text(
                        //   product.rating.toString(),
                        //   style: theme.textTheme.bodySmall,
                        // ),
                      ],
                    ),

                    const Spacer(),

                    // Price
                    Text(
                      product.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
}

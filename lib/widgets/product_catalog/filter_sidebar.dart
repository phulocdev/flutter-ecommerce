import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/brand_api_service.dart';
import 'package:flutter_ecommerce/apis/category_api_service.dart';
import 'package:flutter_ecommerce/models/brand.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/screens/product_catalog_screen.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:intl/intl.dart';

class FilterSidebar extends StatefulWidget {
  final List<String> selectedCategories;
  final RangeValues priceRange;
  final double minRating;
  final List<String> selectedBrands;
  final Function({
    List<String>? categories,
    RangeValues? priceRange,
    double? minRating,
    List<String>? brands,
  }) onApplyFilters;
  final double maxPrice;

  const FilterSidebar({
    Key? key,
    required this.selectedCategories,
    required this.priceRange,
    required this.minRating,
    required this.selectedBrands,
    required this.onApplyFilters,
    required this.maxPrice,
  }) : super(key: key);

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  final CategoryApiService _categoryService = CategoryApiService(ApiClient());
  final BrandApiService _brandService = BrandApiService(ApiClient());

  List<Category> _categories = [];
  List<Brand> _brands = [];

  List<String> _tempSelectedCategories = [];
  RangeValues _tempPriceRange = const RangeValues(0, MAX_PRICE_FILTER);
  double _tempMinRating = 0;
  List<String> _tempSelectedBrands = [];

  @override
  void initState() {
    super.initState();
    _loadFilterData();

    // Initialize temp values from props
    _tempSelectedCategories = List.from(widget.selectedCategories);
    _tempPriceRange = widget.priceRange;
    _tempMinRating = widget.minRating;
    _tempSelectedBrands = List.from(widget.selectedBrands);
  }

  @override
  void didUpdateWidget(FilterSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update temp values if props change
    if (oldWidget.selectedCategories != widget.selectedCategories ||
        oldWidget.priceRange != widget.priceRange ||
        oldWidget.minRating != widget.minRating ||
        oldWidget.selectedBrands != widget.selectedBrands) {
      setState(() {
        _tempSelectedCategories = List.from(widget.selectedCategories);
        _tempPriceRange = widget.priceRange;
        _tempMinRating = widget.minRating;
        _tempSelectedBrands = List.from(widget.selectedBrands);
      });
    }
  }

  Future<void> _loadFilterData() async {
    final categories = await _categoryService.getCategories();
    final brands = await _brandService.getBrands();

    setState(() {
      _categories = categories;
      _brands = brands;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(
      categories: _tempSelectedCategories,
      priceRange: _tempPriceRange,
      minRating: _tempMinRating,
      brands: _tempSelectedBrands,
    );
  }

  void _resetFilters() {
    setState(() {
      _tempSelectedCategories = [];
      _tempPriceRange = RangeValues(0, widget.maxPrice);
      _tempMinRating = 0;
      _tempSelectedBrands = [];
    });

    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    // Determine appropriate heights based on screen size
    final isMobile = ResponsiveBuilder.isMobile(context);
    final isTablet = ResponsiveBuilder.isTablet(context);

    // Calculate heights for scrollable sections
    final double categoryListHeight = 180.00;
    final double brandListHeight = 180.00;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Xóa'),
              ),
            ],
          ),
          const Divider(),

          // Categories filter with limited height and scrolling
          const Text(
            'Danh mục',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: categoryListHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: false, // Important to allow scrolling
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return CheckboxListTile(
                        title: Text(
                          category.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: _tempSelectedCategories.contains(category.id),
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _tempSelectedCategories.add(category.id);
                            } else {
                              _tempSelectedCategories.remove(category.id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          const Divider(),

          // Price range filter
          const Text(
            'Khoảng giá',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _tempPriceRange,
            min: 0,
            max: widget.maxPrice,
            divisions: 400,
            labels: RangeLabels(
              formatter.format(_tempPriceRange.start),
              formatter.format(_tempPriceRange.end),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _tempPriceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatter.format(_tempPriceRange.start)),
              Text(formatter.format(_tempPriceRange.end)),
            ],
          ),
          const Divider(),

          // Rating filter
          const Text(
            'Đánh giá',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _tempMinRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _tempMinRating.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _tempMinRating = value;
                    });
                  },
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  _tempMinRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                color: index < _tempMinRating
                    ? Colors.amber
                    : Colors.grey.shade300,
                size: 20,
              );
            }),
          ),
          const Divider(),

          // Brands filter with limited height and scrolling
          const Text(
            'Thương hiệu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: brandListHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _brands.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: false, // Important to allow scrolling
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      return CheckboxListTile(
                        title: Text(
                          brand.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: _tempSelectedBrands.contains(brand.id),
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _tempSelectedBrands.add(brand.id);
                            } else {
                              _tempSelectedBrands.remove(brand.id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          const Divider(),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Tiến hành lọc'),
            ),
          ),
        ],
      ),
    );
  }
}

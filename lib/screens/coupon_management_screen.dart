import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/coupon_api_service.dart';
import 'package:flutter_ecommerce/models/coupon.dart';
import 'package:flutter_ecommerce/models/dto/coupon_query_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_coupon_dto.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/coupon_form.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:intl/intl.dart';

// Column definitions for the coupon table
final List<Map<String, dynamic>> _columnDefinitions = [
  {'field': 'code', 'text': 'Mã giảm giá', 'flex': 2},
  {'field': 'discountAmount', 'text': 'Giá trị', 'flex': 2},
  {'field': 'usageCount', 'text': 'Đã sử dụng', 'flex': 1},
  {'field': 'maxUsage', 'text': 'Giới hạn', 'flex': 1},
  {'field': 'createdAt', 'text': 'Ngày tạo', 'flex': 2},
  {'field': 'isActive', 'text': 'Trạng thái', 'flex': 2},
  {'field': 'actions', 'text': 'Hành động', 'flex': 2},
];

class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  final couponApiService = CouponApiService(ApiClient());
  final ScrollController _scrollController = ScrollController();
  late List<Coupon> _couponList = [];
  Timer? _debounce;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  int? _selectedDiscountAmount;
  bool? _isActiveFilter;
  int _currentPage = 1;
  final int _pageSize = 10;
  String _sortOption = 'createdAt.desc';
  String _sortField = 'createdAt';
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreCoupons();
    }
  }

  void _updateSortOption(String field) {
    setState(() {
      if (_sortField == field) {
        // Toggle direction if same field
        _sortDirection = _sortDirection == 'asc' ? 'desc' : 'asc';
      } else {
        // New field, default to ascending
        _sortField = field;
        _sortDirection = 'asc';
      }
      _sortOption = '$_sortField.$_sortDirection';
    });
    _fetchData(resetCurrentPage: true);
  }

  Future<void> _fetchData({bool? resetCurrentPage = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = CouponQuery(
        pagination: PaginationQuery(
          page: resetCurrentPage != null ? 1 : _currentPage,
          limit: _pageSize,
        ),
        code: _searchQuery.isNotEmpty ? _searchQuery : null,
        discountAmount: _selectedDiscountAmount,
        isActive: _isActiveFilter,
        sort: _sortOption,
      );

      final couponList = await couponApiService.getCoupons(query: query);

      setState(() {
        _couponList = couponList;
        _isLoading = false;
        _hasMoreData = couponList.length >= _pageSize;
        if (resetCurrentPage == true) {
          _currentPage = 1;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Đã có lỗi xảy ra: $e');
      _showErrorSnackBar('Đã có lỗi xảy ra khi tải dữ liệu');
    }
  }

  Future<void> _loadMoreCoupons() async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = CouponQuery(
        pagination: PaginationQuery(page: _currentPage + 1, limit: _pageSize),
        code: _searchQuery.isNotEmpty ? _searchQuery : null,
        discountAmount: _selectedDiscountAmount,
        isActive: _isActiveFilter,
        sort: _sortOption,
      );

      final newCoupons = await couponApiService.getCoupons(query: query);

      setState(() {
        _couponList.addAll(newCoupons);
        _currentPage++;
        _hasMoreData = newCoupons.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Lỗi khi tải thêm mã giảm giá');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createCoupon(CreateCouponDto dto) async {
    try {
      _showLoadingDialog('Đang tạo mã giảm giá...');

      await couponApiService.create(dto);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Refresh the coupon list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Tạo mã giảm giá thành công');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Lỗi khi tạo mã giảm giá: $e');
      }
    }
  }

  void _toggleCouponStatus(String id, bool newStatus) async {
    try {
      // Show loading
      _showLoadingDialog(newStatus
          ? 'Đang kích hoạt mã giảm giá...'
          : 'Đang vô hiệu hóa mã giảm giá...');

      await couponApiService.toggleStatus(id, newStatus);

      // Close loading dialog
      Navigator.pop(context);

      // Refresh the coupon list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar(newStatus
          ? 'Kích hoạt mã giảm giá thành công'
          : 'Vô hiệu hóa mã giảm giá thành công');
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi thay đổi trạng thái mã giảm giá: $e');
    }
  }

  void _deleteCoupon(String couponId) async {
    try {
      // Show loading
      // _showLoadingDialog('Đang xóa mã giảm giá...');

      await couponApiService.remove(couponId);

      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Xóa mã giảm giá thành công');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi xóa mã giảm giá: $e');
    }
  }

  void _showCreateCouponDialog() {
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(
        onCreate: _createCoupon,
      ),
    );
  }

  void _showCouponDetailsDialog(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(
        coupon: coupon,
        onCreate: _createCoupon,
        onToggleStatus: _toggleCouponStatus,
      ),
    );
  }

  void _handleSearchInputChange(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
        _fetchData(resetCurrentPage: true);
      });
    });
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String couponId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa mã giảm giá này không?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCoupon(couponId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveBuilder.isDesktop(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý mã giảm giá',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý các mã giảm giá của hệ thống',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreateCouponDialog,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text('Tạo mã giảm giá'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Search and filter section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter section title
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bộ lọc tìm kiếm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Đặt lại'),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _selectedDiscountAmount = null;
                                  _isActiveFilter = null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Search field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mã giảm giá',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm mã giảm giá...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: _handleSearchInputChange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Discount amount filter
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     const Text(
                        //       'Giá trị giảm giá',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.w500,
                        //         fontSize: 14,
                        //       ),
                        //     ),
                        //     const SizedBox(height: 8),
                        //     Wrap(
                        //       spacing: 8,
                        //       runSpacing: 8,
                        //       children: [
                        //         _buildCustomChip(
                        //           label: 'Tất cả',
                        //           icon: Icons.money_off,
                        //           selected: _selectedDiscountAmount == null,
                        //           onSelected: (selected) {
                        //             if (selected) {
                        //               setState(() {
                        //                 _selectedDiscountAmount = null;
                        //               });
                        //               _fetchData(resetCurrentPage: true);
                        //             }
                        //           },
                        //           selectedColor: colorScheme.primary,
                        //         ),
                        //         _buildCustomChip(
                        //           label: '10,000 VND',
                        //           icon: Icons.money,
                        //           selected: _selectedDiscountAmount == 10000,
                        //           onSelected: (selected) {
                        //             setState(() {
                        //               _selectedDiscountAmount =
                        //                   selected ? 10000 : null;
                        //             });
                        //             _fetchData(resetCurrentPage: true);
                        //           },
                        //           selectedColor: Colors.green,
                        //         ),
                        //         _buildCustomChip(
                        //           label: '20,000 VND',
                        //           icon: Icons.money,
                        //           selected: _selectedDiscountAmount == 20000,
                        //           onSelected: (selected) {
                        //             setState(() {
                        //               _selectedDiscountAmount =
                        //                   selected ? 20000 : null;
                        //             });
                        //             _fetchData(resetCurrentPage: true);
                        //           },
                        //           selectedColor: Colors.blue,
                        //         ),
                        //         _buildCustomChip(
                        //           label: '50,000 VND',
                        //           icon: Icons.money,
                        //           selected: _selectedDiscountAmount == 50000,
                        //           onSelected: (selected) {
                        //             setState(() {
                        //               _selectedDiscountAmount =
                        //                   selected ? 50000 : null;
                        //             });
                        //             _fetchData(resetCurrentPage: true);
                        //           },
                        //           selectedColor: Colors.orange,
                        //         ),
                        //         _buildCustomChip(
                        //           label: '100,000 VND',
                        //           icon: Icons.money,
                        //           selected: _selectedDiscountAmount == 100000,
                        //           onSelected: (selected) {
                        //             setState(() {
                        //               _selectedDiscountAmount =
                        //                   selected ? 100000 : null;
                        //             });
                        //             _fetchData(resetCurrentPage: true);
                        //           },
                        //           selectedColor: Colors.purple,
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),

                        // const SizedBox(height: 16),

                        // Status filter chips
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildCustomChip(
                              label: 'Tất cả',
                              icon: Icons.list,
                              selected: _isActiveFilter == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _isActiveFilter = null;
                                  });
                                  _fetchData(resetCurrentPage: true);
                                }
                              },
                              selectedColor: colorScheme.primary,
                            ),
                            _buildCustomChip(
                              label: 'Đang hoạt động',
                              icon: Icons.check_circle,
                              selected: _isActiveFilter == true,
                              onSelected: (selected) {
                                setState(() {
                                  _isActiveFilter = selected ? true : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.green,
                            ),
                            _buildCustomChip(
                              label: 'Đã vô hiệu',
                              icon: Icons.block,
                              selected: _isActiveFilter == false,
                              onSelected: (selected) {
                                setState(() {
                                  _isActiveFilter = selected ? false : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.red,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Coupons table with sortable headers
                Expanded(
                  child: _couponList.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            // Table header with sort buttons
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: _columnDefinitions.map((column) {
                                  if (column['field'] == 'actions') {
                                    return Container(
                                      width: 180, // Fixed width for actions
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: const Text(
                                        'Hành động',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return _buildSortableHeader(
                                      field: column['field'],
                                      text: column['text'],
                                      flex: column['flex'],
                                    );
                                  }
                                }).toList(),
                              ),
                            ),

                            // Table body
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _couponList.length,
                                  itemBuilder: (context, index) {
                                    final coupon = _couponList[index];
                                    final isActive = coupon.isActive;

                                    return Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey.shade50,
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Code
                                          Expanded(
                                            flex: _columnDefinitions[0]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                coupon.code,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'monospace',
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Discount Amount
                                          Expanded(
                                            flex: _columnDefinitions[1]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                NumberFormat.currency(
                                                  locale: 'vi_VN',
                                                  symbol: '₫',
                                                  decimalDigits: 0,
                                                ).format(coupon.discountAmount),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Usage Count
                                          Expanded(
                                            flex: _columnDefinitions[2]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                '${coupon.usageCount}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Max Usage
                                          Expanded(
                                            flex: _columnDefinitions[3]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                '${coupon.maxUsage}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Created date
                                          Expanded(
                                            flex: _columnDefinitions[4]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                DateFormat('dd/MM/yyyy')
                                                    .format(coupon.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Status
                                          Expanded(
                                            flex: _columnDefinitions[5]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Center(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isActive
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : Colors.red
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(
                                                    isActive
                                                        ? 'Đang hoạt động'
                                                        : 'Đã vô hiệu',
                                                    style: TextStyle(
                                                      color: isActive
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Actions
                                          Expanded(
                                            flex: _columnDefinitions[6]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // View details button
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.visibility,
                                                        color: Colors.blue),
                                                    tooltip:
                                                        'Xem chi tiết mã giảm giá',
                                                    onPressed: () =>
                                                        _showCouponDetailsDialog(
                                                            coupon),
                                                  ),

                                                  // Toggle status button
                                                  IconButton(
                                                    icon: Icon(
                                                      isActive
                                                          ? Icons.block
                                                          : Icons.check_circle,
                                                      color: isActive
                                                          ? Colors.orange
                                                          : Colors.green,
                                                    ),
                                                    tooltip: isActive
                                                        ? 'Vô hiệu hóa mã'
                                                        : 'Kích hoạt mã',
                                                    onPressed: () =>
                                                        _toggleCouponStatus(
                                                      coupon.id,
                                                      !isActive,
                                                    ),
                                                  ),

                                                  // Delete button
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    tooltip: 'Xóa mã giảm giá',
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                            context, coupon.id),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Loading indicator for infinite loading
                            if (_isLoadingMore)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải dữ liệu...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(
      {required String field, required String text, required int flex}) {
    final bool isActive = _sortField == field;
    final bool isAscending = _sortDirection == 'asc';

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _updateSortOption(field),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? Colors.blue.shade700 : Colors.black,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.discount_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy mã giảm giá',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo mã giảm giá đầu tiên hoặc điều chỉnh bộ lọc tìm kiếm',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateCouponDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tạo mã giảm giá'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Function(bool) onSelected,
    required Color selectedColor,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? selectedColor : Colors.black87,
        ),
      ),
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? selectedColor : Colors.grey,
      ),
      selected: selected,
      onSelected: onSelected,
      elevation: selected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? selectedColor : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: selectedColor.withOpacity(0.1),
      checkmarkColor: selectedColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

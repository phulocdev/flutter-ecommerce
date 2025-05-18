import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/order_api_service.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/models/dto/date_range_query.dart';
import 'package:flutter_ecommerce/models/dto/order_query_dto.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/models/dto/update_order_dto.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:intl/intl.dart';

// First, define the relative sizes for each column
final List<Map<String, dynamic>> _columnDefinitions = [
  {'field': 'code', 'text': 'Mã đơn hàng', 'flex': 2},
  {'field': 'shippingInfo.name', 'text': 'Khách hàng', 'flex': 3},
  {'field': 'totalPrice', 'text': 'Tổng tiền', 'flex': 2},
  {'field': 'itemCount', 'text': 'Số lượng SP', 'flex': 1},
  {'field': 'paymentMethod', 'text': 'Thanh toán', 'flex': 2},
  {'field': 'status', 'text': 'Trạng thái', 'flex': 2},
  {'field': 'createdAt', 'text': 'Ngày tạo', 'flex': 2},
  {'field': 'actions', 'text': 'Hành động', 'flex': 2},
];

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final orderApiService = OrderApiService(ApiClient());
  final ScrollController _scrollController = ScrollController();
  late List<Order> _orderList = [];
  Timer? _debounce;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  int? _statusFilter;
  String _timeRange = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;
  final int _pageSize = 20;
  String _sortOption = 'createdAt.desc';
  String _sortField = 'createdAt';
  String _sortDirection = 'desc';

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

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
      _loadMoreOrders();
    }
  }

  void _updateSortOption(String field) {
    setState(() {
      if (_sortField == field) {
        // Toggle direction if same field
        _sortDirection = _sortDirection == 'asc' ? 'desc' : 'asc';
      } else {
        // New field, default to descending
        _sortField = field;
        _sortDirection = 'desc';
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
      final query = OrderQuery(
        pagination: PaginationQuery(
          page: resetCurrentPage != null ? 1 : _currentPage,
          limit: _pageSize,
        ),
        // dateRange: DateRangeQuery(from: _startDate, to: _endDate) ,
        status: _statusFilter?.toString(),
        sort: _sortOption,
        code: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      final orderList = await orderApiService.getOrders(query: query);

      setState(() {
        _orderList = orderList;
        _isLoading = false;
        _hasMoreData = orderList.length >= _pageSize;
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = OrderQuery(
        pagination: PaginationQuery(page: _currentPage + 1, limit: _pageSize),
        status: _statusFilter.toString(),
        sort: _sortOption,
        code: _searchQuery.isNotEmpty ? _searchQuery : null,
        dateRange: DateRangeQuery(from: _startDate, to: _endDate),
      );

      final newOrders = await orderApiService.getOrders(query: query);

      setState(() {
        _orderList.addAll(newOrders);
        _currentPage++;
        _hasMoreData = newOrders.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Lỗi khi tải thêm đơn hàng');
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

  void _updateOrderStatus(String orderId, int newStatus) async {
    try {
      _showLoadingDialog('Đang cập nhật trạng thái đơn hàng...');

      await orderApiService.update(orderId, UpdateOrderDto(status: newStatus));

      Navigator.pop(context);

      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Cập nhật trạng thái đơn hàng thành công');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi cập nhật trạng thái đơn hàng: $e');
    }
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

  void _setTimeRange(String range) {
    setState(() {
      _timeRange = range;

      final now = DateTime.now();

      switch (range) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
          _endDate = DateTime(
              yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
          break;
        case 'thisWeek':
          // Find the first day of the week (Monday)
          final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(
              firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'thisMonth':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'custom':
          // Keep existing dates or set to null
          _startDate = _startDate ?? now.subtract(const Duration(days: 30));
          _endDate = _endDate ?? now;
          _showDateRangePicker();
          break;
        default:
          _startDate = null;
          _endDate = null;
      }
    });

    if (range != 'custom') {
      _fetchData(resetCurrentPage: true);
    }
  }

  void _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      end: _endDate ?? DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = DateTime(
          pickedDateRange.end.year,
          pickedDateRange.end.month,
          pickedDateRange.end.day,
          23,
          59,
          59,
        );
      });
      _fetchData(resetCurrentPage: true);
    }
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

  String _getOrderStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Đang chuẩn bị';
      case 3:
        return 'Đang giao hàng';
      case 4:
        return 'Đã giao hàng';
      case 5:
        return 'Hoàn thành';
      case 6:
        return 'Đang hoàn trả';
      case 7:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getOrderStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.indigo;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.teal;
      case 5:
        return Colors.green;
      case 6:
        return Colors.amber;
      case 7:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodText(int method) {
    switch (method) {
      case 0:
        return 'Tiền mặt';
      case 1:
        return 'Chuyển khoản';
      case 2:
        return 'Thẻ tín dụng';
      default:
        return 'Không xác định';
    }
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
                          'Quản lý đơn hàng',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý thông tin đơn hàng của hệ thống',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
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
                                  _statusFilter = null;
                                  _timeRange = 'all';
                                  _startDate = null;
                                  _endDate = null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // First row: Order code search
                        if (isDesktop)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mã đơn hàng',
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
                                          hintText:
                                              'Tìm kiếm theo mã đơn hàng...',
                                          prefixIcon: const Icon(Icons.search),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                        ),
                                        onChanged: _handleSearchInputChange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Thời gian',
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
                                      child: DropdownButtonFormField<String>(
                                        value: _timeRange,
                                        decoration: const InputDecoration(
                                          prefixIcon:
                                              Icon(Icons.calendar_today),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'all',
                                            child: Text('Tất cả thời gian'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'today',
                                            child: Text('Hôm nay'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'yesterday',
                                            child: Text('Hôm qua'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'thisWeek',
                                            child: Text('Tuần này'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'thisMonth',
                                            child: Text('Tháng này'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'custom',
                                            child: Text('Tùy chỉnh...'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            _setTimeRange(value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mã đơn hàng',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                                    hintText: 'Tìm kiếm theo mã đơn hàng...',
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
                              const SizedBox(height: 16),
                              const Text(
                                'Thời gian',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _timeRange,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: Text('Tất cả thời gian'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'today',
                                      child: Text('Hôm nay'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'yesterday',
                                      child: Text('Hôm qua'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'thisWeek',
                                      child: Text('Tuần này'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'thisMonth',
                                      child: Text('Tháng này'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'custom',
                                      child: Text('Tùy chỉnh...'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _setTimeRange(value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Status filter chips
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildCustomChip(
                              label: 'Tất cả',
                              icon: Icons.shopping_bag,
                              selected: _statusFilter == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _statusFilter = null;
                                  });
                                  _fetchData(resetCurrentPage: true);
                                }
                              },
                              selectedColor: colorScheme.primary,
                            ),
                            _buildCustomChip(
                              label: 'Chờ xác nhận',
                              icon: Icons.pending_actions,
                              selected: _statusFilter == 0,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 0 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.blue,
                            ),
                            _buildCustomChip(
                              label: 'Đã xác nhận',
                              icon: Icons.check_circle,
                              selected: _statusFilter == 1,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 1 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.indigo,
                            ),
                            _buildCustomChip(
                              label: 'Đang chuẩn bị',
                              icon: Icons.inventory,
                              selected: _statusFilter == 2,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 2 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.purple,
                            ),
                            _buildCustomChip(
                              label: 'Đang giao hàng',
                              icon: Icons.local_shipping,
                              selected: _statusFilter == 3,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 3 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.orange,
                            ),
                            _buildCustomChip(
                              label: 'Đã giao hàng',
                              icon: Icons.home,
                              selected: _statusFilter == 4,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 4 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.teal,
                            ),
                            _buildCustomChip(
                              label: 'Hoàn thành',
                              icon: Icons.done_all,
                              selected: _statusFilter == 5,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 5 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.green,
                            ),
                            _buildCustomChip(
                              label: 'Đang hoàn trả',
                              icon: Icons.assignment_return,
                              selected: _statusFilter == 6,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 6 : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.amber,
                            ),
                            _buildCustomChip(
                              label: 'Đã hủy',
                              icon: Icons.cancel,
                              selected: _statusFilter == 7,
                              onSelected: (selected) {
                                setState(() {
                                  _statusFilter = selected ? 7 : null;
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

                // Orders table with sortable headers
                Expanded(
                  child: _orderList.isEmpty
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
                                    return Expanded(
                                      flex: column['flex'],
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: const Text(
                                          'Hành động',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
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
                                // -------------- ORDER LIST ------------------
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _orderList.length,
                                  itemBuilder: (context, index) {
                                    final order = _orderList[index];

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
                                          // Order code
                                          Expanded(
                                            flex: _columnDefinitions[0]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                order.code,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Customer name
                                          Expanded(
                                            flex: _columnDefinitions[1]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                order.shippingInfo.name,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Total price
                                          Expanded(
                                            flex: _columnDefinitions[2]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                currencyFormatter
                                                    .format(order.totalPrice),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Item count
                                          Expanded(
                                            flex: _columnDefinitions[3]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                order.itemCount.toString(),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Payment method
                                          Expanded(
                                            flex: _columnDefinitions[4]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                _getPaymentMethodText(
                                                    order.paymentMethod),
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
                                                    color: _getOrderStatusColor(
                                                            order.status)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(
                                                    _getOrderStatusText(
                                                        order.status),
                                                    style: TextStyle(
                                                      color:
                                                          _getOrderStatusColor(
                                                              order.status),
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

                                          // Created date
                                          Expanded(
                                            flex: _columnDefinitions[6]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                DateFormat('dd/MM/yyyy HH:mm')
                                                    .format(order.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Actions
                                          Expanded(
                                            flex: _columnDefinitions[7]['flex'],
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
                                                        'Xem chi tiết đơn hàng',
                                                    onPressed: () {
                                                      navigateTo(
                                                        context,
                                                        '${AppRoute.orderManagement.path}/:id',
                                                        pathParameters: {
                                                          'id': order.id
                                                        },
                                                      );
                                                    },
                                                  ),

                                                  // Update status button
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit_note,
                                                      color: Colors.orange,
                                                    ),
                                                    tooltip:
                                                        'Cập nhật trạng thái',
                                                    onPressed: () =>
                                                        _showUpdateStatusDialog(
                                                      context,
                                                      order.id,
                                                      order.status,
                                                    ),
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

  void _showUpdateStatusDialog(
      BuildContext context, String orderId, int currentStatus) {
    int selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Cập nhật trạng thái đơn hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn trạng thái mới cho đơn hàng:'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem(value: 0, child: Text('Chờ xác nhận')),
                    DropdownMenuItem(value: 1, child: Text('Đã xác nhận')),
                    DropdownMenuItem(value: 2, child: Text('Đang chuẩn bị')),
                    DropdownMenuItem(value: 3, child: Text('Đang giao hàng')),
                    DropdownMenuItem(value: 4, child: Text('Đã giao hàng')),
                    DropdownMenuItem(value: 5, child: Text('Hoàn thành')),
                    DropdownMenuItem(value: 6, child: Text('Đang hoàn trả')),
                    DropdownMenuItem(value: 7, child: Text('Đã hủy')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedStatus != currentStatus) {
                  _updateOrderStatus(orderId, selectedStatus);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cập nhật'),
            ),
          ],
        );
      }),
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
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy đơn hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Điều chỉnh bộ lọc tìm kiếm để xem các đơn hàng khác',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
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

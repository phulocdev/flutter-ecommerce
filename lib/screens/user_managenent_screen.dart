import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/user_api_service.dart';
import 'package:flutter_ecommerce/models/dto/create_user_dto.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/models/dto/update_user_dto.dart';
import 'package:flutter_ecommerce/models/dto/user_query_dto.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:flutter_ecommerce/widgets/user_form_dialog.dart';
import 'package:intl/intl.dart';

// For user_management_screen.dart
final List<Map<String, dynamic>> _columnDefinitions = [
  {'field': 'fullName', 'text': 'Họ và tên', 'flex': 3},
  {'field': 'email', 'text': 'Email', 'flex': 3},
  {'field': 'phoneNumber', 'text': 'Số điện thoại', 'flex': 2},
  {'field': 'role', 'text': 'Vai trò', 'flex': 1},
  {'field': 'createdAt', 'text': 'Ngày tạo', 'flex': 2},
  {'field': 'isActive', 'text': 'Trạng thái', 'flex': 2},
  {'field': 'actions', 'text': 'Hành động', 'flex': 2},
];

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final userApiService = UserApiService(ApiClient());
  final ScrollController _scrollController = ScrollController();
  late List<User> _userList = [];
  Timer? _debounce;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  String _emailFilter = '';
  String? _selectedRole;
  int? _isActiveFilter;
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
      _loadMoreUsers();
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

  Future<void> _fetchData({bool? resetCurrentPage}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = UserQuery(
        pagination: PaginationQuery(
          page: resetCurrentPage != null ? 1 : _currentPage,
          limit: _pageSize,
        ),
        role: _selectedRole,
        sort: _sortOption,
        fullName: _searchQuery.isNotEmpty ? _searchQuery : null,
        email: _emailFilter.isNotEmpty ? _emailFilter : null,
        isActive: _isActiveFilter,
      );

      final userList = await userApiService.getUsers(query: query);

      setState(() {
        _userList = userList;
        _isLoading = false;
        _hasMoreData = userList.length >= _pageSize;
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

  Future<void> _loadMoreUsers() async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = UserQuery(
        pagination: PaginationQuery(page: _currentPage + 1, limit: _pageSize),
        role: _selectedRole,
        sort: _sortOption,
        fullName: _searchQuery.isNotEmpty ? _searchQuery : null,
        email: _emailFilter.isNotEmpty ? _emailFilter : null,
        isActive: _isActiveFilter,
      );

      final newUsers = await userApiService.getUsers(query: query);

      setState(() {
        _userList.addAll(newUsers);
        _currentPage++;
        _hasMoreData = newUsers.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Lỗi khi tải thêm người dùng');
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

  void _addUser(CreateUserDto dto) async {
    try {
      _showLoadingDialog('Đang thêm người dùng...');

      await userApiService.create(dto);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Refresh the user list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Thêm người dùng thành công');
    } on ApiException catch (e) {
      if (mounted) {
        if (e.statusCode == 422 && e.errors != null && e.errors!.isNotEmpty) {
          final errorMessages =
              e.errors!.map((err) => err['message']).join(', ');
          _showErrorSnackBar(errorMessages);
        } else {
          _showErrorSnackBar(e.message);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi không xác định: $e')),
        );
      }
    }
  }

  void _updateUser(String id, UpdateUserDto dto) async {
    try {
      _showLoadingDialog('Đang cập nhật người dùng...');

      // In a real app, you would call the API
      await userApiService.update(id, dto);

      Navigator.pop(context);

      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Cập nhật người dùng thành công');
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        if (e.statusCode == 422 && e.errors != null && e.errors!.isNotEmpty) {
          final errorMessages =
              e.errors!.map((err) => err['message']).join(', ');
          _showErrorSnackBar(errorMessages);
        } else {
          _showErrorSnackBar('Cập nhật người dùng thất bại: ${e.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi không xác định: $e')),
        );
      }
    }
  }

  void _deleteUser(String userId) async {
    try {
      // Show loading
      _showLoadingDialog('Đang xóa người dùng...');

      await userApiService.remove(userId);

      Navigator.pop(context);
      _fetchData(resetCurrentPage: true);

      _showSuccessSnackBar('Xóa người dùng thành công');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi xóa người dùng: $e');
    }
  }

  void _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      // Show loading
      _showLoadingDialog(currentStatus
          ? 'Đang khóa người dùng...'
          : 'Đang mở khóa người dùng...');

      await userApiService.update(
          userId, UpdateUserDto(isActive: !currentStatus));

      // Close loading dialog
      Navigator.pop(context);

      // Refresh the user list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar(currentStatus
          ? 'Khóa người dùng thành công'
          : 'Mở khóa người dùng thành công');
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi thay đổi trạng thái người dùng: $e');
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onCreate: _addUser,
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

  void _handleEmailInputChange(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _emailFilter = value;
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
                          'Quản lý người dùng',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý thông tin người dùng của hệ thống',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddUserDialog,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text('Thêm người dùng'),
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
                                  _emailFilter = '';
                                  _selectedRole = null;
                                  _isActiveFilter = null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // First row: Name search and role filter
                        if (isDesktop)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tên người dùng',
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
                                          hintText: 'Tìm kiếm theo tên...',
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
                                      'Email',
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
                                          hintText: 'Tìm kiếm theo email...',
                                          prefixIcon: const Icon(Icons.email),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                        ),
                                        onChanged: _handleEmailInputChange,
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
                                'Tên người dùng',
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
                                    hintText: 'Tìm kiếm theo tên...',
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
                              const SizedBox(height: 8),
                            ],
                          ),

                        const SizedBox(height: 4),

                        // Second row: Email filter and status filter
                        const SizedBox(width: 16),
                        if (!isDesktop)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
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
                                    hintText: 'Tìm kiếm theo email...',
                                    prefixIcon: const Icon(Icons.email),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                  onChanged: _handleEmailInputChange,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                              icon: Icons.people,
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
                              selected: _isActiveFilter == 1,
                              onSelected: (selected) {
                                setState(() {
                                  _isActiveFilter = selected ? 1 : 0;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.green,
                            ),
                            _buildCustomChip(
                              label: 'Đã khóa',
                              icon: Icons.block,
                              selected: _isActiveFilter == 0,
                              onSelected: (selected) {
                                setState(() {
                                  _isActiveFilter = selected ? 0 : 1;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.red,
                            ),
                            _buildCustomChip(
                              label: 'Quản trị viên',
                              icon: Icons.admin_panel_settings,
                              selected: _selectedRole == 'Admin',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRole = selected ? 'Admin' : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.purple,
                            ),
                            _buildCustomChip(
                              label: 'Khách hàng',
                              icon: Icons.person,
                              selected: _selectedRole == 'Customer',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRole = selected ? 'Customer' : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              selectedColor: Colors.blue,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Users table with sortable headers
                Expanded(
                  child: _userList.isEmpty
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
                                  itemCount: _userList.length,
                                  itemBuilder: (context, index) {
                                    final user = _userList[index];
                                    final isActive = user.isActive ?? true;

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
                                        children: // User Management Table Cells
                                            [
                                          // Full name
                                          Expanded(
                                            flex: _columnDefinitions[0]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                user.fullName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Email
                                          Expanded(
                                            flex: _columnDefinitions[1]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                user.email,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Phone
                                          Expanded(
                                            flex: _columnDefinitions[2]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                user.phoneNumber.isEmpty
                                                    ? 'Chưa cập nhật'
                                                    : user.phoneNumber,
                                                style: TextStyle(
                                                  color: user.phoneNumber
                                                          .isNotEmpty
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade400,
                                                  fontStyle: user.phoneNumber
                                                          .isNotEmpty
                                                      ? FontStyle.normal
                                                      : FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Role
                                          Expanded(
                                            flex: _columnDefinitions[3]['flex'],
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
                                                    color:
                                                        _getRoleColor(user.role)
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(
                                                    _getLocalizedRole(
                                                        user.role),
                                                    style: TextStyle(
                                                      color: _getRoleColor(
                                                          user.role),
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
                                            flex: _columnDefinitions[4]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                user.createdAt != null
                                                    ? DateFormat('dd/MM/yyyy')
                                                        .format(user.createdAt!)
                                                    : 'Không rõ',
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
                                                        : 'Đã khóa',
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
                                                  // Edit button
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    tooltip:
                                                        'Chỉnh sửa người dùng',
                                                    onPressed: () =>
                                                        _showEditDialog(
                                                            context, user),
                                                  ),

                                                  // Ban/Unban button
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
                                                        ? 'Khóa người dùng'
                                                        : 'Mở khóa người dùng',
                                                    onPressed: () =>
                                                        _showToggleStatusConfirmation(
                                                      context,
                                                      user.id,
                                                      isActive,
                                                    ),
                                                  ),

                                                  // Delete button
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    tooltip: 'Xóa người dùng',
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                            context, user.id),
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

  String _getLocalizedRole(String role) {
    switch (role) {
      case 'Admin':
        return 'Quản trị viên';
      case 'Staff':
        return 'Nhân viên';
      case 'Customer':
        return 'Khách hàng';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'staff':
        return Colors.orange;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTableCell({
    required int flex,
    required Widget child,
  }) {
    // Calculate minimum width based on flex
    final double minWidth = 100.0 * flex;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: child,
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

  void _showEditDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
          user: user,
          onUpdate: (updateUserDto) {
            _updateUser(user.id, updateUserDto);
          }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa người dùng này không?'),
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
              _deleteUser(userId);
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

  void _showToggleStatusConfirmation(
      BuildContext context, String userId, bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus
            ? 'Xác nhận khóa người dùng'
            : 'Xác nhận mở khóa người dùng'),
        content: Text(currentStatus
            ? 'Bạn có chắc chắn muốn khóa người dùng này không? Họ sẽ không thể đăng nhập vào hệ thống.'
            : 'Bạn có chắc chắn muốn mở khóa người dùng này không? Họ sẽ có thể đăng nhập vào hệ thống.'),
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
              _toggleUserStatus(userId, currentStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(currentStatus ? 'Khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy người dùng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm người dùng đầu tiên hoặc điều chỉnh bộ lọc tìm kiếm',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm người dùng'),
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

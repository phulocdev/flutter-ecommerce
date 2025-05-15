import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_ecommerce/models/dto/user_query_dto.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:flutter_ecommerce/widgets/user_form_dialog.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // final userApiService = UserApiService(ApiClient());
  final ScrollController _scrollController = ScrollController();
  late List<User> _userList = [];
  Timer? _debounce;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  String _emailFilter = '';
  String? _selectedRole;
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

  Future<void> _fetchData({bool? resetCurrentPage = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // final query = UserQuery(
      //   pagination: PaginationQuery(
      //     page: resetCurrentPage != null ? 1 : _currentPage,
      //     limit: _pageSize,
      //   ),
      //   role: _selectedRole,
      //   sort: _sortOption,
      //   fullName: _searchQuery.isNotEmpty ? _searchQuery : null,
      //   email: _emailFilter.isNotEmpty ? _emailFilter : null,
      //   isActive: _isActiveFilter,
      // );

      // Simulate API call with Future.delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would call the API
      // final userList = await userApiService.getUsers(query: query);

      // For demo purposes, we'll use mock data
      final userList = _getMockUsers();

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
      // final query = UserQuery(
      //   pagination: PaginationQuery(page: _currentPage + 1, limit: _pageSize),
      //   role: _selectedRole,
      //   sort: _sortOption,
      //   fullName: _searchQuery.isNotEmpty ? _searchQuery : null,
      //   email: _emailFilter.isNotEmpty ? _emailFilter : null,
      //   isActive: _isActiveFilter,
      // );

      // Simulate API call with Future.delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would call the API
      // final newUsers = await userApiService.getUsers(query: query);

      // For demo purposes, we'll use mock data
      final newUsers = _getMockUsers();

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

  void _addUser(User user) async {
    try {
      // Show loading
      _showLoadingDialog('Đang thêm người dùng...');

      // Simulate API call with Future.delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call the API
      // await userApiService.createUser(user);

      // Close loading dialog
      Navigator.pop(context);

      // Refresh the user list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Thêm người dùng thành công');
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi thêm người dùng: $e');
    }
  }

  void _updateUser(User user) async {
    try {
      // Show loading
      _showLoadingDialog('Đang cập nhật người dùng...');

      // Simulate API call with Future.delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call the API
      // await userApiService.updateUser(user);

      // Close loading dialog
      Navigator.pop(context);

      // Refresh the user list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Cập nhật người dùng thành công');
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi cập nhật người dùng: $e');
    }
  }

  void _deleteUser(String userId) async {
    try {
      // Show loading
      _showLoadingDialog('Đang xóa người dùng...');

      // Simulate API call with Future.delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call the API
      // await userApiService.deleteUser(userId);

      // Close loading dialog
      Navigator.pop(context);

      // Refresh the user list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Xóa người dùng thành công');
    } catch (e) {
      // Close loading dialog
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

      // Simulate API call with Future.delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call the API
      // await userApiService.updateUserStatus(userId, !currentStatus);

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
        onSave: _addUser,
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

  // Mock data for demo purposes
  List<User> _getMockUsers() {
    return [
      User(
        id: '1',
        email: 'admin@example.com',
        fullName: 'Nguyễn Văn Admin',
        role: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
        phone: '0123456789',
        address: 'Hà Nội, Việt Nam',
      ),
      User(
        id: '2',
        email: 'user1@example.com',
        fullName: 'Trần Thị Khách Hàng',
        role: 'Customer',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
        phone: '0987654321',
        address: 'Hồ Chí Minh, Việt Nam',
      ),
      User(
        id: '3',
        email: 'user2@example.com',
        fullName: 'Lê Văn Người Dùng',
        role: 'Customer',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isActive: false,
        phone: '0369852147',
        address: 'Đà Nẵng, Việt Nam',
      ),
      User(
        id: '4',
        email: 'staff@example.com',
        fullName: 'Phạm Thị Nhân Viên',
        role: 'Staff',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isActive: true,
        phone: '0912345678',
        address: 'Hải Phòng, Việt Nam',
      ),
      User(
        id: '5',
        email: 'user3@example.com',
        fullName: 'Hoàng Văn Khách',
        role: 'Customer',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
        phone: '0898765432',
        address: 'Cần Thơ, Việt Nam',
      ),
    ];
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
                                      'Vai trò',
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          isExpanded: true,
                                          hint: const Text('Chọn vai trò'),
                                          value: _selectedRole,
                                          items: const [
                                            DropdownMenuItem<String?>(
                                              value: null,
                                              child: Text('Tất cả vai trò'),
                                            ),
                                            DropdownMenuItem<String?>(
                                              value: 'Admin',
                                              child: Text('Quản trị viên'),
                                            ),
                                            DropdownMenuItem<String?>(
                                              value: 'Staff',
                                              child: Text('Nhân viên'),
                                            ),
                                            DropdownMenuItem<String?>(
                                              value: 'Customer',
                                              child: Text('Khách hàng'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRole = value;
                                            });
                                            _fetchData(resetCurrentPage: true);
                                          },
                                        ),
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
                              const Text(
                                'Vai trò',
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String?>(
                                    isExpanded: true,
                                    hint: const Text('Chọn vai trò'),
                                    value: _selectedRole,
                                    items: const [
                                      DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Tất cả vai trò'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'Admin',
                                        child: Text('Quản trị viên'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'Staff',
                                        child: Text('Nhân viên'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'Customer',
                                        child: Text('Khách hàng'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                      _fetchData(resetCurrentPage: true);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 4),

                        // Second row: Email filter and status filter
                        if (isDesktop)
                          Row(
                            children: [
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
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trạng thái',
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<bool?>(
                                          isExpanded: true,
                                          hint: const Text('Chọn trạng thái'),
                                          value: _isActiveFilter,
                                          items: const [
                                            DropdownMenuItem<bool?>(
                                              value: null,
                                              child: Text('Tất cả trạng thái'),
                                            ),
                                            DropdownMenuItem<bool?>(
                                              value: true,
                                              child: Text('Đang hoạt động'),
                                            ),
                                            DropdownMenuItem<bool?>(
                                              value: false,
                                              child: Text('Đã khóa'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _isActiveFilter = value;
                                            });
                                            _fetchData(resetCurrentPage: true);
                                          },
                                        ),
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
                              const Text(
                                'Trạng thái',
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<bool?>(
                                    isExpanded: true,
                                    hint: const Text('Chọn trạng thái'),
                                    value: _isActiveFilter,
                                    items: const [
                                      DropdownMenuItem<bool?>(
                                        value: null,
                                        child: Text('Tất cả trạng thái'),
                                      ),
                                      DropdownMenuItem<bool?>(
                                        value: true,
                                        child: Text('Đang hoạt động'),
                                      ),
                                      DropdownMenuItem<bool?>(
                                        value: false,
                                        child: Text('Đã khóa'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _isActiveFilter = value;
                                      });
                                      _fetchData(resetCurrentPage: true);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Status filter chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('Tất cả'),
                              selected: _isActiveFilter == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _isActiveFilter = null;
                                  });
                                  _fetchData(resetCurrentPage: true);
                                }
                              },
                              avatar: const Icon(Icons.people),
                              backgroundColor: Colors.grey.shade100,
                              selectedColor:
                                  colorScheme.primary.withOpacity(0.1),
                              checkmarkColor: colorScheme.primary,
                            ),
                            FilterChip(
                              label: const Text('Đang hoạt động'),
                              selected: _isActiveFilter == true,
                              onSelected: (selected) {
                                setState(() {
                                  _isActiveFilter = selected ? true : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              avatar: const Icon(Icons.check_circle),
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Colors.green.withOpacity(0.1),
                              checkmarkColor: Colors.green,
                            ),
                            FilterChip(
                              label: const Text('Đã khóa'),
                              selected: _isActiveFilter == false,
                              onSelected: (selected) {
                                setState(() {
                                  _isActiveFilter = selected ? false : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              avatar: const Icon(Icons.block),
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Colors.red.withOpacity(0.1),
                              checkmarkColor: Colors.red,
                            ),
                            FilterChip(
                              label: const Text('Quản trị viên'),
                              selected: _selectedRole == 'Admin',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRole = selected ? 'Admin' : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              avatar: const Icon(Icons.admin_panel_settings),
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Colors.purple.withOpacity(0.1),
                              checkmarkColor: Colors.purple,
                            ),
                            FilterChip(
                              label: const Text('Khách hàng'),
                              selected: _selectedRole == 'Customer',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRole = selected ? 'Customer' : null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              avatar: const Icon(Icons.person),
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Colors.blue.withOpacity(0.1),
                              checkmarkColor: Colors.blue,
                            ),
                          ],
                        ),
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
                                children: [
                                  _buildSortableHeader(
                                      field: 'fullName',
                                      text: 'Họ và tên',
                                      width: 350),
                                  _buildSortableHeader(
                                      field: 'email',
                                      text: 'Email',
                                      width: 350),
                                  _buildSortableHeader(
                                      field: 'phone',
                                      text: 'Số điện thoại',
                                      width: 200),
                                  _buildSortableHeader(
                                      field: 'role',
                                      text: 'Vai trò',
                                      width: 150),
                                  _buildSortableHeader(
                                      field: 'createdAt',
                                      text: 'Ngày tạo',
                                      width: 200),
                                  _buildSortableHeader(
                                      field: 'isActive',
                                      text: 'Trạng thái',
                                      width: 150),
                                  Container(
                                    width: 180,
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
                                ],
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
                                // -------------- USER LIST ------------------
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
                                        children: [
                                          // Full name
                                          Container(
                                            width: 350,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              user.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          // Email
                                          Container(
                                            width: 350,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              user.email,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),

                                          // Phone
                                          Container(
                                            width: 200,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              user.phone ?? 'Chưa cập nhật',
                                              style: TextStyle(
                                                color: user.phone != null
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade400,
                                                fontStyle: user.phone != null
                                                    ? FontStyle.normal
                                                    : FontStyle.italic,
                                              ),
                                            ),
                                          ),

                                          // Role
                                          Container(
                                            width: 150,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getRoleColor(user.role)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                _getLocalizedRole(user.role),
                                                style: TextStyle(
                                                  color:
                                                      _getRoleColor(user.role),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Created date
                                          Container(
                                            width: 200,
                                            padding: const EdgeInsets.symmetric(
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

                                          // Status
                                          Container(
                                            width: 150,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                isActive
                                                    ? 'Đang hoạt động'
                                                    : 'Đã khóa',
                                                style: TextStyle(
                                                  color: isActive
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Actions
                                          Container(
                                            width: 180,
                                            padding: const EdgeInsets.symmetric(
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
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  tooltip: 'Xóa người dùng',
                                                  onPressed: () =>
                                                      _showDeleteConfirmation(
                                                          context, user.id),
                                                ),
                                              ],
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

  Widget _buildSortableHeader(
      {required String field, required String text, double? width}) {
    final bool isActive = _sortField == field;
    final bool isAscending = _sortDirection == 'asc';

    return InkWell(
      onTap: () => _updateSortOption(field),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
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
    );
  }

  void _showEditDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onSave: _updateUser,
      ),
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
}

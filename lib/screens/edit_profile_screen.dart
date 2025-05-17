import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/image_upload_service_v2.dart';
import 'package:flutter_ecommerce/apis/user_api_service.dart';
import 'package:flutter_ecommerce/models/dto/login_response_dto.dart';
import 'package:flutter_ecommerce/models/dto/update_user_dto.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:flutter_ecommerce/widgets/custom_text_form_field.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final userApiService = UserApiService(ApiClient());
  final _tokenService = TokenService();
  final imageUploadService = ImageUploadApiServiceV2();

  dynamic _avatarImage;
  final ImagePicker _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    final account = ref.read(authProvider);
    super.initState();
    _nameController.text = account?.fullName ?? '';
    _addressController.text = account?.address ?? '';
    _emailController.text = account?.email ?? '';
    _phoneController.text = account?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            // For web, read as bytes
            pickedFile.readAsBytes().then((bytes) {
              _avatarImage = bytes;
            });
          } else {
            // For mobile, use File
            _avatarImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final account = ref.read(authProvider);
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload avatar if user selected a new image
        String? newAvatarUrl = account?.avatarUrl;
        if (_avatarImage != null) {
          try {
            if (kIsWeb && _avatarImage is Uint8List) {
              // For web, use the bytes directly
              newAvatarUrl = await imageUploadService.apiClient.uploadImage(
                imageBytes: _avatarImage,
                folderName: 'avatars-flutter',
                fileName:
                    'avatar_${account!.id}_${DateTime.now().millisecondsSinceEpoch}',
              );
            } else if (!kIsWeb && _avatarImage is File) {
              // For mobile, read the file into bytes first
              final File file = _avatarImage as File;
              final bytes = await file.readAsBytes();
              newAvatarUrl = await imageUploadService.apiClient.uploadImage(
                imageBytes: bytes,
                folderName: 'avatars-flutter',
                fileName:
                    'avatar_${account!.id}_${DateTime.now().millisecondsSinceEpoch}',
              );
            }
            print('Avatar uploaded successfully: $newAvatarUrl');
          } catch (e) {
            print('Failed to upload avatar image: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Failed to upload avatar: ${e.toString()}')),
              );
            }
          }
        }

        final dto = UpdateUserDto(
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          isChangeEmail: _emailController.text.trim() != account?.email,
          isChangePhoneNumber:
              _phoneController.text.trim() != account?.phoneNumber,
          avatarUrl: newAvatarUrl,
        );

        await userApiService.update(account!.id, dto);

        // Create new Account object with updated fields
        final updatedAccount = Account(
          id: account.id,
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          role: account.role,
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          avatarUrl: newAvatarUrl ??
              account.avatarUrl, // Use new avatar URL if available
        );

        ref.read(authProvider.notifier).setAccount(updatedAccount);
        _tokenService.saveAccount(updatedAccount);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thông tin đã được cập nhật'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit, color: Colors.lightBlue),
            SizedBox(width: 8),
            Text(
              'Chỉnh sửa thông tin',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildProfileForm(isMobile: true),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: _buildProfileForm(isMobile: false),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(32),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: _buildProfileForm(isMobile: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm({required bool isMobile}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar section
          _buildAvatarSection(),
          const SizedBox(height: 32),

          // Form fields
          isMobile ? _buildMobileFormFields() : _buildWideFormFields(),

          const SizedBox(height: 32),

          // Save button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _buildAvatarImage(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Chạm để thay đổi ảnh đại diện',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    final account = ref.read(authProvider);

    if (_avatarImage != null) {
      // Show selected image
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.blue.shade100,
        backgroundImage: _getImageProvider(),
      );
    } else if (account?.avatarUrl != null && account!.avatarUrl.isNotEmpty) {
      // Show existing avatar from URL
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.blue.shade100,
        backgroundImage: NetworkImage(account.avatarUrl),
      );
    } else {
      // Show default avatar
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.blue.shade100,
        backgroundImage: const AssetImage('assets/images/avt.png'),
      );
    }
  }

  ImageProvider _getImageProvider() {
    if (_avatarImage != null) {
      if (kIsWeb && _avatarImage is Uint8List) {
        return MemoryImage(_avatarImage as Uint8List);
      } else if (!kIsWeb && _avatarImage is File) {
        return FileImage(_avatarImage as File);
      }
    }
    return const AssetImage('assets/images/avt.png');
  }

  Widget _buildMobileFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin cá nhân'),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _nameController,
          label: 'Họ và tên',
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _emailController,
          label: 'Email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _phoneController,
          label: 'Số điện thoại',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Địa chỉ giao hàng'),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _addressController,
          label: 'Địa chỉ',
          prefixIcon: Icons.location_on,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập địa chỉ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWideFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin cá nhân'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: _nameController,
                label: 'Họ và tên',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextFormField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Thông tin liên hệ'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: _phoneController,
                label: 'Số điện thoại',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextFormField(
                controller: _addressController,
                label: 'Địa chỉ',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveProfile,
        icon: _isLoading
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.lightBlue,
          elevation: 2,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

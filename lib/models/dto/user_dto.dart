// Đổi tên từ UserResponseDto thành UserDto
class UserDto {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  UserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}

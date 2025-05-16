class CreateUserDto {
  final String email;
  final String fullName;
  final String password;
  final String? role;
  final bool? isActive;
  final String? phoneNumber;
  final String? address;

  CreateUserDto({
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.address,
    required this.isActive,
    required this.password,
  });

  CreateUserDto copyWith({
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? address,
    bool? isActive,
    String? password,
  }) {
    return CreateUserDto(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'password': password,
      if (role != null) 'role': role,
      if (isActive != null) 'isActive': isActive,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
    };
  }
}

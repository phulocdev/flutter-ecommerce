class UpdateUserDto {
  final String? fullName;
  final String? role;
  final String? phoneNumber;
  final String? address;
  final bool? isActive;
  final String? password;

  UpdateUserDto({
    this.fullName,
    this.role,
    this.phoneNumber,
    this.address,
    this.isActive,
    this.password,
  });

  UpdateUserDto copyWith({
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? address,
    bool? isActive,
    String? password,
  }) {
    return UpdateUserDto(
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (fullName != null) data['fullName'] = fullName;
    if (role != null) data['role'] = role;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    if (isActive != null) data['isActive'] = isActive;
    if (password != null) data['password'] = password;

    return data;
  }
}

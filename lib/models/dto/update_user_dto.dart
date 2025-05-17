class UpdateUserDto {
  final String? email;
  final String? fullName;
  final String? role;
  final String? phoneNumber;
  final String? address;
  final bool? isChangePhoneNumber;
  final bool? isChangeEmail;
  final bool? isActive;
  final String? password;
  final String? avatarUrl;

  UpdateUserDto(
      {this.email,
      this.fullName,
      this.role,
      this.phoneNumber,
      this.address,
      this.isActive,
      this.isChangeEmail,
      this.isChangePhoneNumber,
      this.password,
      this.avatarUrl});

  UpdateUserDto copyWith({
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? address,
    bool? isChangePhoneNumber,
    bool? isChangeEmail,
    bool? isActive,
    String? password,
    String? avatarUrl,
  }) {
    return UpdateUserDto(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isChangePhoneNumber: isChangePhoneNumber ?? this.isChangePhoneNumber,
      isChangeEmail: isChangeEmail ?? this.isChangeEmail,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (email != null) data['email'] = email;
    if (fullName != null) data['fullName'] = fullName;
    if (role != null) data['role'] = role;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    if (isChangePhoneNumber != null)
      data['isChangePhoneNumber'] = isChangePhoneNumber;
    if (isChangeEmail != null) data['isChangeEmail'] = isChangeEmail;
    if (isActive != null) data['isActive'] = isActive;
    if (password != null) data['password'] = password;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    return data;
  }
}

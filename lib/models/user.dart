class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final DateTime? createdAt;
  final bool? isActive;
  final String? phone;
  final String? address;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.createdAt,
    this.isActive,
    this.phone,
    this.address,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
    bool? isActive,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isActive: json['isActive'] as bool?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
      'phone': phone,
      'address': address,
    };
  }
}

class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final DateTime? createdAt; // Made nullable for backward compatibility
  final bool? isActive; // Made nullable for backward compatibility
  final String? phone; // Optional field
  final String? address; // Optional field

  User({
    required this.email,
    required this.fullName,
    required this.role,
    this.id = '', // Default empty string for backward compatibility
    this.createdAt,
    this.isActive,
    this.phone,
    this.address,
  });

  // Add fromJson factory constructor for API compatibility
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'],
      fullName: json['fullName'] ?? json['name'] ?? '', // Handle both fullName and name
      role: json['role'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      isActive: json['isActive'] ?? true,
      phone: json['phone'],
      address: json['address'],
    );
  }

  // Add toJson method for API compatibility
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

  // Helper method to create a copy with updated fields
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
}
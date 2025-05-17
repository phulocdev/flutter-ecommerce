class User {
  final String _id;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;
  final bool isActive;
  final String phoneNumber;
  final String address;
  final String password; // <-- Added field

  const User({
    required String id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    required this.isActive,
    required this.phoneNumber,
    required this.address,
    required this.password, // <-- Add to constructor
  }) : _id = id;

  String get id => _id;

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
    bool? isActive,
    String? phoneNumber,
    String? address,
    String? password, // <-- Add to copyWith
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      password: password ?? this.password, // <-- Add this
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'address': address,
      'password': password,
    };
  }
}

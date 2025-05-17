class LoginResponseDto {
  final int statusCode;
  final String message;
  final Data data;

  LoginResponseDto({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class Data {
  final String accessToken;
  final String refreshToken;
  final Account account;

  Data({
    required this.accessToken,
    required this.refreshToken,
    required this.account,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );
  }
}

class Account {
  final String _id;
  final String avatarUrl;
  final String email;
  final String fullName;
  final String role;
  final String address;
  final String phoneNumber;

  Account({
    required String id,
    required this.avatarUrl,
    required this.email,
    required this.fullName,
    required this.role,
    required this.address,
    required this.phoneNumber,
  }) : _id = id;

  String get id => _id;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'] as String,
      avatarUrl: json['avatarUrl'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

class RegisterForGuestResponseDto {
  final int statusCode;
  final String message;
  final Account data;

  RegisterForGuestResponseDto({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory RegisterForGuestResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterForGuestResponseDto(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: Account.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

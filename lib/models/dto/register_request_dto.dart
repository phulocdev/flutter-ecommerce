class RegisterRequestDto {
  final String fullName;
  final String address;
  final String email;
  final String password;

  RegisterRequestDto({
    required this.fullName,
    required this.address,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'email': email,
      'password': password,
    };
  }
}

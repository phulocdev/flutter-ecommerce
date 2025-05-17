class ResetPasswordDto {
  final String email;
  final String password;
  final int otpCode;

  ResetPasswordDto({
    required this.email,
    required this.password,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'otpCode': otpCode,
    };
  }
}

class ForgotPasswrodDto {
  final String email;

  ForgotPasswrodDto({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class RegisterForGuestRequestDto {
  final String email;
  final String fullName;
  final String address;

  RegisterForGuestRequestDto({
    required this.fullName,
    required this.address,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'email': email,
    };
  }
}

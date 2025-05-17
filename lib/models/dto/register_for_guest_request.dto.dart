class RegisterForGuestRequestDto {
  final String email;
  final String fullName;
  final String address;
  final String phoneNumber;

  RegisterForGuestRequestDto(
      {required this.fullName,
      required this.address,
      required this.email,
      required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}

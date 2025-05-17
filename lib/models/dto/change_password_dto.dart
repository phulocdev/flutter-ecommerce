class ChangePasswrodDto {
  final String oldPassword;
  final String newPassword;

  ChangePasswrodDto({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}

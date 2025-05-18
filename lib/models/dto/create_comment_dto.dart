class CreateCommentDto {
  final String productId;
  final String? accountId;
  final String? content;
  final String? name;
  final String? email;
  final double? stars;

  CreateCommentDto({
    required this.productId,
    this.accountId,
    this.content,
    this.name,
    this.email,
    this.stars,
  });

  CreateCommentDto copyWith({
    String? productId,
    String? accountId,
    String? content,
    String? name,
    String? email,
    double? stars,
  }) {
    return CreateCommentDto(
      productId: productId ?? this.productId,
      accountId: accountId ?? this.accountId,
      content: content ?? this.content,
      name: name ?? this.name,
      email: email ?? this.email,
      stars: stars ?? this.stars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      if (accountId != null) 'accountId': accountId,
      if (content != null) 'content': content,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (stars != null) 'stars': stars,
    };
  }
}

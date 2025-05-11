class AttributeOption {
  final String name;
  final List<String> values;

  const AttributeOption({
    required this.name,
    required this.values,
  });

  factory AttributeOption.fromJson(Map<String, dynamic> json) =>
      AttributeOption(
        name: json['name'] as String,
        values: List<String>.from(json['values']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'values': values,
      };
}

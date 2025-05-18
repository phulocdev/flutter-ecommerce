class UpdateOrderDto {
  final int status;

  UpdateOrderDto({required this.status});

  UpdateOrderDto copyWith({required int status}) {
    return UpdateOrderDto(status: status);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['status'] = status;

    return data;
  }
}

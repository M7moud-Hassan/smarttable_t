class SubstituteModel {
  final int id;
  final String name;
  final bool available;
  final String? busyReason;

  SubstituteModel({
    required this.id,
    required this.name,
    required this.available,
    this.busyReason,
  });

  factory SubstituteModel.fromJson(Map<String, dynamic> json) {
    return SubstituteModel(
      id: json['id'] as int,
      name: json['name'] as String,
      available: json['available'] as bool? ?? false,
      busyReason: json['busy_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'available': available,
      'busy_reason': busyReason,
    };
  }
}

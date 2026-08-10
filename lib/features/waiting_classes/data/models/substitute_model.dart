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
      id: _asInt(json['teacher_id'] ?? json['id']),
      name: (json['teacher_name'] ?? json['name'] ?? '').toString(),
      available:
          json['is_available'] as bool? ?? json['available'] as bool? ?? false,
      busyReason: _firstNonEmpty(
        json['unavailable_reason'],
        json['busy_reason'],
      ),
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

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _firstNonEmpty(dynamic first, dynamic second) {
  for (final value in [first, second]) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

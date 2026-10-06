Map<String, dynamic> readJsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<T> readJsonList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) mapper,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

String readJsonString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final result = value.toString();
  return result.isEmpty ? fallback : result;
}

int readJsonInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? readNullableJsonInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return readJsonInt(value);
}

double readJsonDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool readJsonBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' || 'yes' => true,
    'false' || '0' || 'no' => false,
    _ => fallback,
  };
}

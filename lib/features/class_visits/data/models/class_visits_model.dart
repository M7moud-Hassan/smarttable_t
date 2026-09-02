class ClassVisitsModel {
  int id;
  String teacherName;
  String visitorName;
  String session;
  String className;
  String date;
  String dateHijri;
  String? rate;
  String? fileUrl;

  String get rateLabel {
    final value = rate?.trim();
    return value == null || value.isEmpty ? '-' : value;
  }

  double? get ratingValue {
    final value = rate?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;

    final numericValue = double.tryParse(value.replaceAll(',', '.'));
    if (numericValue != null) return _validRating(numericValue);

    final fractionMatch =
        RegExp(r'^([0-5](?:[.,]\d+)?)\s*/\s*5$').firstMatch(value);
    if (fractionMatch != null) {
      return _validRating(
        double.parse(fractionMatch.group(1)!.replaceAll(',', '.')),
      );
    }

    final normalizedValue = value
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll(RegExp(r'[\s_-]+'), '');

    return switch (normalizedValue) {
      'ممتاز' || 'excellent' => 5,
      'جيدجدا' || 'verygood' => 4,
      'جيد' || 'good' => 3,
      'مقبول' || 'acceptable' || 'fair' => 2,
      'ضعيف' || 'weak' || 'poor' => 1,
      _ => null,
    };
  }

  ClassVisitsModel({
    required this.id,
    required this.teacherName,
    required this.visitorName,
    required this.session,
    required this.className,
    required this.date,
    required this.dateHijri,
    this.rate,
    this.fileUrl,
  });

  factory ClassVisitsModel.fromJson(Map<String, dynamic> json) =>
      ClassVisitsModel(
        id: json["id"],
        teacherName: json["teacher_name"] ?? '',
        visitorName: json["visitor_name"] ?? '',
        session: json["session"] ?? '',
        className: json["class_name"] ?? '',
        date: json["date"] ?? '',
        dateHijri: json["date_hijri"] ?? '',
        rate: json["rate"]?.toString(),
        fileUrl: json["file_url"] ?? json["file"],
      );

  static double? _validRating(double value) {
    return value >= 0 && value <= 5 ? value : null;
  }
}

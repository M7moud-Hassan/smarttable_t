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
  ClassVisitEvaluation? evaluation;
  bool hasEvaluation;

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
    this.evaluation,
    this.hasEvaluation = false,
  });

  factory ClassVisitsModel.fromJson(Map<String, dynamic> json) =>
      ClassVisitsModel(
        id: json["id"],
        teacherName: json["teacher_name"] ?? '',
        visitorName: json["visitor_name"] ?? '',
        session: json["session"]?.toString() ?? '',
        className: json["class_name"] ?? '',
        date: json["date"] ?? '',
        dateHijri: json["date_hijri"] ?? '',
        rate: (json['overall_evaluation'] ??
                (json['evaluation'] is Map
                    ? json['evaluation']['overall_evaluation'] ??
                        json['evaluation']['visit_evaluation']
                    : null) ??
                json['rate'])
            ?.toString(),
        hasEvaluation:
            json['has_evaluation'] == true || json['evaluation'] is Map,
        evaluation: json['evaluation'] is Map
            ? ClassVisitEvaluation.fromJson(
                Map<String, dynamic>.from(json['evaluation']))
            : null,
        fileUrl: json["file_url"] ?? json["file"],
      );

  static double? _validRating(double value) {
    return value >= 0 && value <= 5 ? value : null;
  }
}

class ClassVisitEvaluation {
  ClassVisitEvaluation(this.sections, this.notes);
  final List<ClassVisitEvaluationSection> sections;
  final Map<String, String> notes;

  factory ClassVisitEvaluation.fromJson(Map<String, dynamic> json) {
    const definitions = <String, Map<String, String>>{
      'planing': {
        'title': 'التخطيط',
        'clarity_lesson': 'وضوح أهداف الدرس',
        'lesson_content_appropriate': 'ملاءمة محتوى الدرس',
        'appropriate_educational_methods': 'ملاءمة الوسائل التعليمية'
      },
      'implementation': {
        'title': 'التنفيذ',
        'clarity_explanation': 'وضوح الشرح',
        'diversity_strategies': 'تنوع استراتيجيات التدريس',
        'invest_time': 'استثمار الوقت'
      },
      'interaction': {
        'title': 'التفاعل والتقويم',
        'student_interaction': 'تفاعل الطلاب',
        'various_evaluation': 'تنوع أساليب التقويم',
        'provide_feed': 'تقديم التغذية الراجعة'
      },
      'managment': {
        'title': 'الإدارة الصفية',
        'controlling_student_behavior': 'ضبط سلوك الطلاب',
        'organizing_classroom': 'تنظيم البيئة الصفية',
        'invest_class_time': 'استثمار وقت الحصة'
      },
    };
    final sections = <ClassVisitEvaluationSection>[];
    for (final entry in definitions.entries) {
      final raw = json[entry.key];
      if (raw is! Map) continue;
      sections.add(ClassVisitEvaluationSection(
        title: entry.value['title']!,
        score: json['${entry.key}_evaluation']?.toString() ?? '-',
        items: {
          for (final item in entry.value.entries)
            if (item.key != 'title')
              item.value: raw[item.key]?.toString() ?? '-'
        },
        note: raw['note']?.toString() ?? '',
      ));
    }
    return ClassVisitEvaluation(sections, {
      'ملاحظات التقييم العام': json['visit_evaluation_note']?.toString() ?? '',
      'نقاط القوة': json['strengths']?.toString() ?? '',
      'مجالات التحسين': json['areas_improvement']?.toString() ?? '',
      'التوصيات': json['recommendations']?.toString() ?? '',
    });
  }
}

class ClassVisitEvaluationSection {
  ClassVisitEvaluationSection(
      {required this.title,
      required this.score,
      required this.items,
      required this.note});
  final String title;
  final String score;
  final Map<String, String> items;
  final String note;
}

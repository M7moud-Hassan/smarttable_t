class LessonAchievementDraft {
  const LessonAchievementDraft({
    required this.cellNumber,
    required this.date,
    required this.achievement,
    required this.homework,
    this.notes = '',
  });

  final int cellNumber;
  final DateTime date;
  final String achievement;
  final String homework;
  final String notes;

  Map<String, dynamic> toJson() => {
        'cell_number': cellNumber,
        'date': formatLessonAchievementDate(date),
        'achievement': achievement.trim(),
        'homework': homework.trim(),
        'notes': notes.trim(),
      };
}

class LessonAchievement {
  const LessonAchievement({
    required this.id,
    required this.cellNumber,
    required this.date,
    required this.achievement,
    required this.homework,
    required this.notes,
  });

  final int id;
  final int? cellNumber;
  final DateTime? date;
  final String achievement;
  final String homework;
  final String notes;

  factory LessonAchievement.fromJson(Map<String, dynamic> json) {
    return LessonAchievement(
      id: _asInt(json['id']) ?? 0,
      cellNumber: _asInt(
        json['cell_number'] ??
            _nestedValue(json['cell'], const ['cell_number', 'number', 'id']),
      ),
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      achievement: json['achievement']?.toString() ?? '',
      homework: json['homework']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  bool isForDate(DateTime value) {
    final achievementDate = date;
    return achievementDate != null &&
        achievementDate.year == value.year &&
        achievementDate.month == value.month &&
        achievementDate.day == value.day;
  }
}

class LessonAchievementPatch {
  const LessonAchievementPatch({
    this.achievement,
    this.homework,
    this.notes,
  });

  final String? achievement;
  final String? homework;
  final String? notes;

  bool get isEmpty => achievement == null && homework == null && notes == null;

  Map<String, dynamic> toJson() => {
        if (achievement != null) 'achievement': achievement!.trim(),
        if (homework != null) 'homework': homework!.trim(),
        if (notes != null) 'notes': notes!.trim(),
      };
}

String formatLessonAchievementDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

dynamic _nestedValue(dynamic value, List<String> keys) {
  if (value is! Map) return null;
  for (final key in keys) {
    if (value[key] != null) return value[key];
  }
  return null;
}

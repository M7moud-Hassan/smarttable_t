class ClassesTimingSettings {
  final int classesNotificationsMinutesBefore;
  final bool enableClassesNotifications;
  final String hashed;
  final List<ClassTiming> classesTiming;

  ClassesTimingSettings({
    required this.enableClassesNotifications,
    required this.classesNotificationsMinutesBefore,
    required this.classesTiming,
    required this.hashed,
  });

  factory ClassesTimingSettings.fromJson(Map<String, dynamic> json) {
    return ClassesTimingSettings(
      enableClassesNotifications: json['enable_classes_notifications'] ?? false,
      classesNotificationsMinutesBefore:
          json['classes_notifications_minutes_before'] ?? 0,
      classesTiming: (json['classes_timing'] as List<dynamic>?)
              ?.map((e) => ClassTiming.fromJson(e))
              .toList() ??
          [],
      hashed: json['hashed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_classes_notifications': enableClassesNotifications,
      'classes_notifications_minutes_before': classesNotificationsMinutesBefore,
      'classes_timing': classesTiming.map((e) => e.toJson()).toList(),
    };
  }

  ClassesTimingSettings copyWith({
    bool? enableClassesNotifications,
    String? hashed,
    int? classesNotificationsMinutesBefore,
    List<ClassTiming>? classesTiming,
  }) {
    return ClassesTimingSettings(
      enableClassesNotifications:
          enableClassesNotifications ?? this.enableClassesNotifications,
      classesNotificationsMinutesBefore: classesNotificationsMinutesBefore ??
          this.classesNotificationsMinutesBefore,
      classesTiming: classesTiming ?? this.classesTiming,
      hashed: hashed ?? this.hashed,
    );
  }
}

class ClassTiming {
  final String dayen;
  final String startTime;
  final String cellNumberText;
  final String cellText;

  ClassTiming({
    required this.dayen,
    required this.startTime,
    required this.cellNumberText,
    required this.cellText,
  });

  factory ClassTiming.fromJson(Map<String, dynamic> json) {
    return ClassTiming(
      dayen: json['day_en'] ?? '',
      startTime: json['start_time'] ?? '',
      cellNumberText: json['cell_number_text'] ?? '',
      cellText: json['cell_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayen': dayen,
      'start_time': startTime,
      'cell_number_text': cellNumberText,
      'cell_text': cellText,
    };
  }
}

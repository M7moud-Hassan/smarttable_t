import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/school_table/data/models/day_model.dart';
import '../../features/school_table/data/models/lesson_model.dart';

String countryCodeToEmoji(String countryCode) {
  // Ensure the country code is uppercase
  countryCode = countryCode.toUpperCase();
  // Calculate the flag emoji
  return String.fromCharCode(countryCode.codeUnitAt(0) + 0x1F1E6 - 65) +
      String.fromCharCode(countryCode.codeUnitAt(1) + 0x1F1E6 - 65);
}

List<String> getHeaderClassesList(List<LessonModel> lessons) {
  List<String> headerClasses = [];
  for (var element in lessons) {
    if (!headerClasses.contains(element.classNumberText)) {
      headerClasses.add(element.classNumberText);
    }
  }
  return headerClasses;
}

Future<void> shareText(String text) async {
  await Share.share(text);
}

Future<void> openLink(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}

Future<File?> pickFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );
    final platformFile = result?.files.firstOrNull;
    if (platformFile == null || platformFile.path == null) return null;

    return File(platformFile.path!);
  } catch (e) {
    return null;
  }
}

String getFileNameFromPath(String path) {
  final parts = path.split('/');
  return parts.last;
}

Map<int, List<LessonModel>> prepareLessonsData(
    List<LessonModel> lessons, List<DaysOfWeekModel> days, int length) {
  Map<int, List<LessonModel>> dataMap = {};
  for (var day in days) {
    final List<LessonModel> lessonsList =
        List.filled(length, LessonModel.init(), growable: false);
    dataMap.addAll({day.id: lessonsList});
    for (var lesson in lessons) {
      if (lesson.dayId == day.id) {
        lessonsList[int.parse(lesson.classNumber) - 1] = lesson;
      }
    }
    dataMap[day.id] = lessonsList;
  }
  return dataMap;
}

String? translateWeekday(BuildContext context, String englishName) {
  final Map<String, Map<String, String>> translations = {
    'en': {
      'sunday': 'Sunday',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
    },
    'ar': {
      'sunday': 'الأحد',
      'monday': 'الإثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
      'saturday': 'السبت',
    }
  };

  final locale = Localizations.localeOf(context).languageCode;
  final lowerKey = englishName.toLowerCase();

  return translations[locale]?[lowerKey] ?? translations['en']![lowerKey];
}

TimeOfDay parseTimeOfDay(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

int getWeekdayNumber(String dayName) {
  const dayMap = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
  };

  return dayMap[dayName.toLowerCase()]!;
}

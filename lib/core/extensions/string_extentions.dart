import 'package:flutter/material.dart';

extension StringExtetions on String {
  Color toHexColor() {
    final hexString = '0XFF$this';
    return Color(int.parse(hexString.replaceAll('#', '')));
  }

  DateTime toDateTime() {
    return DateTime.parse(this);
  }
}

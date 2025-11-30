import 'package:flutter/material.dart';

class LayoutModel {
  final String title;
  final String activeIcon;
  final String inActiveIcon;
  final Widget page;
  final String pageTitle;

  LayoutModel({
    required this.title,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.page,
    required this.pageTitle,
  });
}

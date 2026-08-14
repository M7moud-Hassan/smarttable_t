import 'package:flutter/material.dart';

class TeacherPreferencesTheme extends StatelessWidget {
  const TeacherPreferencesTheme({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'PingAR'),
        primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'PingAR'),
      ),
      child: child,
    );
  }
}

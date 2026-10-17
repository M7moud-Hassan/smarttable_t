import 'package:flutter/widgets.dart';

const double maxAppTextScaleFactor = 1.15;

class AppTextScaleBoundary extends StatelessWidget {
  const AppTextScaleBoundary({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxAppTextScaleFactor,
      child: child,
    );
  }
}

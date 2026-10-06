import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';

class StudentReportStat extends StatelessWidget {
  const StudentReportStat({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white,
      side: BorderSide(
        color: color?.withValues(alpha: .55) ?? const Color(0xFFD7D7D7),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class StudentReportEntry extends StatelessWidget {
  const StudentReportEntry({
    super.key,
    required this.title,
    required this.details,
    required this.trailing,
  });

  final String title;
  final String details;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD7D7D7)),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: trailing,
      ),
    );
  }
}

class ReportError extends StatelessWidget {
  const ReportError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

class EmptyReport extends StatelessWidget {
  const EmptyReport({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

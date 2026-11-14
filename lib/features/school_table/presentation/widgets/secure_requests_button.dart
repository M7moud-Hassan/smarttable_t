import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/waiting_classes/presentation/views/secure_class_requests_view.dart';

class SecureRequestsButton extends StatelessWidget {
  const SecureRequestsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0FAFA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(const SecureClassRequestsView()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt_outlined,
                    color: AppColors.secondryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلبات المعلم البديل',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'متابعة الطلبات والرد عليها',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: AppColors.secondryColor),
            ],
          ),
        ),
      ),
    );
  }
}

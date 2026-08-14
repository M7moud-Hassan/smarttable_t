import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/features/teacher_preferences/presentation/widgets/teacher_preferences_theme.dart';

class TeacherPreferenceSuccessView extends StatelessWidget {
  const TeacherPreferenceSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TeacherPreferencesTheme(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 56,
            backgroundColor: Colors.white,
            centerTitle: true,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: AppColors.primaryColor),
            title: const Text(
              'إضافة الرغبات',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(23),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondryColor,
                        width: 5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.secondryColor,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'تم إضافة الرغبات\nبنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: 27,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

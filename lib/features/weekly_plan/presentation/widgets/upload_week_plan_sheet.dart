import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/providers/request_response_provider.dart';
import 'package:smart_table_app/features/weekly_plan/providers/weekly_plan_notififer.dart';

import '../../../../core/providers/picked_file_provider.dart';
import '../../../../core/utils/helpers.dart';
import '../../providers/week_info_provider.dart';

class UploadWeekPlanSheet extends ConsumerWidget {
  const UploadWeekPlanSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(requestResponseProvider, (_, state) {
      if (state.state == RequestResponseState.error) {
        context.pop();
        context.showSnackbarError(context.locale.errorMessage);
      } else if (state.state == RequestResponseState.success) {
        context.pop();
        // Since we need to show the success view, we will just push it!
        // We simulate Image 2.
        context.pushReplacement(const SuccessUploadView());
      }
    });

    final pickedFile = ref.watch(pickedFileProvider);
    final selectedWeek = ref.watch(selectedWeekProvider);
    final isPicked = pickedFile != null && selectedWeek != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إضافة خطة جديدة'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ref.watch(weekInfoProvider(1)).when(
              data: (data) {
                final weeks = data.list;
                return DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryColor,
                  ),
                  hint: Text(
                    'اختر اسبوع الخطة',
                    style: context.textTheme.titleMedium!.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  value: selectedWeek != null && weeks.any((w) => w.id == selectedWeek.id)
                      ? selectedWeek.id
                      : null,
                  items: weeks.map((week) {
                    return DropdownMenuItem<int>(
                      value: week.id,
                      child: Text(
                        week.weekNumberText,
                        style: context.textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final week = weeks.firstWhere((w) => w.id == value);
                      ref.read(selectedWeekProvider.notifier).state = week;
                    }
                  },
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryColor),
                  color: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    Text('جاري التحميل...'),
                  ],
                ),
              ),
              error: (err, stack) => Text('حدث خطأ أثناء تحميل الأسابيع',
                  style: context.textTheme.titleMedium!.copyWith(color: Colors.red)),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final pickedFile = await pickFile();
                if (pickedFile != null) {
                  ref.read(pickedFileProvider.notifier).state = pickedFile;
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (!isPicked) ...[
                      const Icon(
                        Icons.upload_file, // Or file_upload
                        size: 40,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'تحميل الملف',
                        style: context.textTheme.titleMedium!.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ] else ...[
                      Image.asset(
                        PngAssets.pdf,
                        width: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        getFileNameFromPath(pickedFile.path),
                        style: context.textTheme.titleMedium!.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isPicked
                    ? () {
                        // show loading or similar if needed
                        ref
                            .read(weeklyPlanNotififerProvider.notifier)
                            .uploadFile(selectedWeek.id);
                      }
                    : null,
                child: const Text(
                  'تأكيد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SuccessUploadView extends StatelessWidget {
  const SuccessUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إضافة خطة جديدة'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.primaryColor,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'تم إضافة الخطة\nالاسبوعية بنجاح',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge!.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

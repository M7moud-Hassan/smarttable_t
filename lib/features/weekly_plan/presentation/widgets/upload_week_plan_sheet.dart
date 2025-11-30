import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/providers/request_response_provider.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/app_text_field.dart';
import 'package:smart_table_app/features/weekly_plan/providers/weekly_plan_notififer.dart';

import '../../../../core/providers/picked_file_provider.dart';
import '../../../../core/utils/helpers.dart';
import '../../providers/week_info_provider.dart';
import '../views/week_info_view.dart';

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
        context.showSnackbarSuccess(context.locale.sucessMessage);
      }
    });
    final pickedFile = ref.watch(pickedFileProvider);
    final selectedWeek = ref.watch(selectedWeekProvider);

    final isPicked = pickedFile != null && selectedWeek != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            readOnly: true,
            onTap: () => context.push(const WeeklyInfoView()),
            hintText: context.locale.selectWeek,
            controller:
                TextEditingController(text: selectedWeek?.weekNumberText ?? ''),
            suffixIcon: const RotatedBox(
              quarterTurns: 3,
              child: Icon(
                Icons.arrow_forward_ios_sharp,
                size: 15,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () async {
              final pickedFile = await pickFile();
              if (pickedFile != null) {
                ref.read(pickedFileProvider.notifier).state = pickedFile;
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [3, 3],
                color: AppColors.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      !isPicked
                          ? const Icon(
                              Icons.upload_file_outlined,
                              size: 50,
                              color: AppColors.primaryColor,
                            )
                          : Image.asset(
                              PngAssets.pdf,
                              width: 50,
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        isPicked
                            ? getFileNameFromPath(pickedFile.path)
                            : context.locale.chooseFile,
                        style: context.textTheme.titleLarge!.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppButton(
            onPressed: isPicked
                ? () {
                    ref
                        .read(weeklyPlanNotififerProvider.notifier)
                        .uploadFile(selectedWeek.id);
                  }
                : null,
            child: Text(
              context.locale.uploadFile,
            ),
          ),
        ],
      ),
    );
  }
}

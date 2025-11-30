import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/helpers.dart';
import 'package:smart_table_app/core/utils/utils.dart';
import 'package:smart_table_app/core/widgets/app_text_field.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/custom_expansion_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/class_timing/data/models/class_timing_model.dart';
import 'package:smart_table_app/features/class_timing/providers/class_timing_notifer.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog_widget.dart';

class ClassTimingView extends ConsumerWidget {
  const ClassTimingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classTimingAsync = ref.watch(classTimingProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(context.locale.classTiming),
        ),
        body: Padding(
          padding: pgHorizontalPadding18,
          child: classTimingAsync.when(
              data: (classTiming) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(classTiming.enableClassesNotifications
                            ? context.locale.classTimingToggleDisable
                            : context.locale.classTimingToggleEnable),
                        subtitle: classTiming.enableClassesNotifications
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(context.locale
                                      .classTimingNotificationTime(classTiming
                                          .classesNotificationsMinutesBefore
                                          .toString())),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) => EditClassTimingDialog(
                                                classTiming: classTiming,
                                              ));
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        value: classTiming.enableClassesNotifications,
                        onChanged: (value) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmDialogWidget(
                                    title: value
                                        ? context.locale
                                            .enableClassTimingConfirmation
                                        : context.locale
                                            .disableClassTimingConfirmation,
                                    onConfirm: () {
                                      final data = ClassesTimingSettings(
                                          enableClassesNotifications: value,
                                          classesNotificationsMinutesBefore: 5,
                                          classesTiming: [],
                                          hashed: classTiming.hashed);
                                      ref
                                          .read(
                                              classTimingMangeProvider.notifier)
                                          .toggoleClassTiming(data);
                                    });
                              });
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        context.locale.riminders,
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Expanded(
                          child: classTiming.classesTiming.isEmpty
                              ? Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notification_add_outlined,
                                      size: 45,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(context.locale.classTimingNoTimings),
                                  ],
                                ))
                              : ListView.separated(
                                  itemBuilder: (_, index) {
                                    final item =
                                        classTiming.classesTiming[index];
                                    return CustomExpansionWidget(
                                        titleWidget: Text(
                                          translateWeekday(
                                                  context, item.dayen) ??
                                              '',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        contentWidget: [
                                          ListTile(
                                            title: Text(
                                              item.cellText,
                                            ),
                                          )
                                        ]);
                                  },
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(
                                    height: 10,
                                  ),
                                  itemCount: classTiming.classesTiming.length,
                                ))
                    ],
                  ),
              error: (error, stackTrace) => CustomErrorWidget(
                    onTap: () => ref.invalidate(classTimingProvider),
                  ),
              loading: () => const LoadingWidget()),
        ));
  }
}

class EditClassTimingDialog extends ConsumerStatefulWidget
    with ValidationMixin {
  const EditClassTimingDialog({
    super.key,
    required this.classTiming,
  });

  final ClassesTimingSettings classTiming;

  @override
  ConsumerState<EditClassTimingDialog> createState() =>
      _EditClassTimingDialogState();
}

class _EditClassTimingDialogState extends ConsumerState<EditClassTimingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.classTiming.classesNotificationsMinutesBefore.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedValue = int.parse(_controller.text.trim());

      final data = widget.classTiming.copyWith(
        classesNotificationsMinutesBefore: updatedValue,
      );
      context.pop();

      ref.read(classTimingMangeProvider.notifier).toggoleClassTiming(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.locale.editClassTiming,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            AppTextField(
              hintText: '',
              controller: _controller,
              textInputType: TextInputType.number,
              textInputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (val) => widget.classTimeValidation(val, context),
            ),
            const SizedBox(height: 30),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(
                context.locale.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              onPressed: _submit,
              child: Text(context.locale.confirm),
            ),
          ],
        ),
      ),
    );
  }
}

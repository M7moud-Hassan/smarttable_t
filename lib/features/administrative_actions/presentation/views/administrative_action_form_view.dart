import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/administrative_actions/data/models/administrative_action_model.dart';
import 'package:smart_table_app/features/administrative_actions/providers/administrative_actions_provider.dart';

class AdministrativeActionFormView extends ConsumerStatefulWidget {
  const AdministrativeActionFormView({
    super.key,
    required this.action,
  });

  final AdministrativeActionModel action;

  @override
  ConsumerState<AdministrativeActionFormView> createState() =>
      _AdministrativeActionFormViewState();
}

class _AdministrativeActionFormViewState
    extends ConsumerState<AdministrativeActionFormView> {
  final _reasonController = TextEditingController();
  bool _isDetailsExpanded = true;
  bool _didInitializeReason = false;

  AdministrativeProcedureKey get _procedureKey => AdministrativeProcedureKey(
        procedureType: widget.action.procedureType,
        id: widget.action.id,
      );

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail =
        ref.watch(administrativeActionDetailsProvider(_procedureKey));
    final replyState = ref.watch(administrativeActionReplyProvider);
    final screenTitle =
        _formTitle(detail.asData?.value.title ?? widget.action.title);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.secondryColor),
          title: Text(
            screenTitle,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        body: detail.when(
          data: (item) {
            if (!_didInitializeReason) {
              _didInitializeReason = true;
              _reasonController.text = item.teacherReason;
            }
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              children: [
                _ActionDetailsPanel(
                  detail: item,
                  isExpanded: _isDetailsExpanded,
                  onToggle: () => setState(
                    () => _isDetailsExpanded = !_isDetailsExpanded,
                  ),
                ),
                const SizedBox(height: 24),
                _ReasonPanel(
                  controller: _reasonController,
                  label: item.reasonLabel.isEmpty
                      ? 'سبب الإجراء'
                      : item.reasonLabel,
                  hint: item.reasonHint.isEmpty
                      ? 'اكتب إفادتك على الإجراء الإداري'
                      : item.reasonHint,
                  canReply: item.canReply,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            );
          },
          loading: () => const Center(child: LoadingWidget()),
          error: (error, _) => CustomErrorWidget(
            error: error is Exception
                ? exceptionHandler(context: context, exception: error)
                : null,
            onTap: () => ref.invalidate(
              administrativeActionDetailsProvider(_procedureKey),
            ),
          ),
        ),
        bottomNavigationBar: detail.asData == null
            ? null
            : SafeArea(
                minimum: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    onPressed: _canSubmit(detail.requireValue, replyState)
                        ? _submit
                        : null,
                    child: replyState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            detail.requireValue.canReply
                                ? 'إرسال للمدير'
                                : 'تم إرسال الإفادة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
      ),
    );
  }

  bool _canSubmit(
    AdministrativeActionDetailModel detail,
    AsyncValue<void> replyState,
  ) {
    return detail.canReply &&
        !replyState.isLoading &&
        _reasonController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final success = await ref
        .read(administrativeActionReplyProvider.notifier)
        .submit(_procedureKey, _reasonController.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }
    final error = ref.read(administrativeActionReplyProvider).error;
    final message = error is Exception
        ? exceptionHandler(context: context, exception: error)
        : null;
    context.showSnackbarError(message ?? context.locale.errorMessage);
  }

  String _formTitle(String title) {
    if (title == 'تنبيه على الإنصراف') return 'تنبيه إنصراف';
    return title.replaceFirst(' على ', ' ');
  }
}

class _ActionDetailsPanel extends StatelessWidget {
  const _ActionDetailsPanel({
    required this.detail,
    required this.isExpanded,
    required this.onToggle,
  });

  final AdministrativeActionDetailModel detail;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final details = detail.details.isNotEmpty
        ? detail.details
        : <AdministrativeActionDetailItem>[
            AdministrativeActionDetailItem(
              label: 'نوع الإجراء',
              value: detail.title,
            ),
            AdministrativeActionDetailItem(
              label: 'التاريخ',
              value: detail.date,
            ),
          ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: SizedBox(
              height: 49,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primaryColor,
                      size: 21,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        detail.title.contains('تنبيه')
                            ? 'بيانات التنبيه'
                            : 'بيانات الإجراء',
                        style: const TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            for (final item in details) ...[
              const Divider(height: 1, color: AppColors.primaryColor),
              _DetailsRow(label: item.label, value: item.value),
            ],
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondryColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 92),
          ],
        ),
      ),
    );
  }
}

class _ReasonPanel extends StatelessWidget {
  const _ReasonPanel({
    required this.controller,
    required this.label,
    required this.hint,
    required this.canReply,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool canReply;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 13, 10, 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF242424),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF595959),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            readOnly: !canReply,
            minLines: 4,
            maxLines: 5,
            maxLength: 255,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'اكتب هنا ....',
              hintStyle: const TextStyle(
                color: AppColors.textGrayColor,
                fontSize: 13,
              ),
              filled: !canReply,
              fillColor: !canReply ? AppColors.grayColor : null,
              counterText: '',
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grayBordredColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grayBordredColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

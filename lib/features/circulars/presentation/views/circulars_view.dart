import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/views/pdf_viewer_view.dart';
import 'package:smart_table_app/core/widgets/download_button.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';
import 'package:smart_table_app/features/circulars/data/models/circulars_model.dart';

import '../../providers/teacher_notes_provider.dart';

class CircularsView extends ConsumerWidget {
  const CircularsView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PaginationListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        getList: (page) => ref.read(circularsProvider(page).future),
        itemBuilder: (circular, index) => Column(
          children: [
            for (final task in circular.tasks) _CircularItemCard(task: task)
          ],
        ),
        noItemWidget: Center(
          child: Text(context.locale.noData),
        ),
      ),
    );
  }
}

class _CircularItemCard extends ConsumerStatefulWidget {
  final Tasks task;

  const _CircularItemCard({required this.task});

  @override
  ConsumerState<_CircularItemCard> createState() => _CircularItemCardState();
}

class _CircularItemCardState extends ConsumerState<_CircularItemCard> {
  bool _isExpanded = false;
  late bool _isSigned;

  @override
  void initState() {
    super.initState();
    _isSigned = widget.task.isSigned;
  }

  @override
  void didUpdateWidget(covariant _CircularItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || widget.task.isSigned) {
      _isSigned = widget.task.isSigned;
    }
  }

  Future<void> _signCircular() async {
    final success =
        await ref.read(circularSignProvider(widget.task.id).notifier).sign();
    if (!mounted) return;

    if (success) {
      setState(() => _isSigned = true);
      final message = ref.read(circularSignProvider(widget.task.id)).value;
      context.showSnackbarSuccess(
        message?.trim().isNotEmpty == true
            ? message!
            : context.locale.circularSignedSuccessfully,
      );
      return;
    }

    final error = ref.read(circularSignProvider(widget.task.id)).error;
    final message = error is Exception
        ? exceptionHandler(context: context, exception: error)
        : null;
    context.showSnackbarError(
      message?.trim().isNotEmpty == true
          ? message!
          : context.locale.errorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final signState = ref.watch(circularSignProvider(widget.task.id));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          if (widget.task.fileIcon == 'pdf') ...[
                            Image.asset(
                              PngAssets.pdf,
                              width: 24,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              widget.task.title,
                              style: context.textTheme.titleMedium!.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    key: ValueKey('circular-sign-${widget.task.id}'),
                    onPressed:
                        _isSigned || signState.isLoading ? null : _signCircular,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE8F5EC),
                      disabledForegroundColor: const Color(0xFF27834D),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: signState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _isSigned
                                ? Icons.check_circle_outline_rounded
                                : Icons.draw_outlined,
                            size: 19,
                          ),
                    label: Text(
                      _isSigned
                          ? context.locale.circularSigned
                          : context.locale.signCircular,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _isExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${context.locale.date} : ${widget.task.dateHijri}',
                                style: context.textTheme.titleSmall!.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.task.details,
                            style: context.textTheme.titleMedium!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    context.push(PdfViwerView(
                                      title: widget.task.title,
                                      url: widget.task.fileUrl,
                                    ));
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: AppColors.primaryColor,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        context.locale.show,
                                        style: context.textTheme.titleMedium!
                                            .copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DownloadButtonWidget(
                                  link: widget.task.fileUrl,
                                  fileName: widget.task.fileName,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'حفظ Pdf',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.download_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

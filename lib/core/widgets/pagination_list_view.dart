import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../models/pagination_model.dart';

class PaginationListView<T> extends ConsumerStatefulWidget {
  final PagingController<int, T>? controller;
  final Future<PaginationModel<T>> Function(int) getList;
  final Widget Function(T, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final Widget noItemWidget;
  final Widget? sepratedWidget;

  const PaginationListView({
    super.key,
    this.controller,
    required this.getList,
    required this.itemBuilder,
    required this.noItemWidget,
    this.padding,
    this.sepratedWidget,
  });

  @override
  ConsumerState<PaginationListView<T>> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T> extends ConsumerState<PaginationListView<T>> {
  late final PagingController<int, T> controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? PagingController(firstPageKey: 1);
    controller.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final data = await widget.getList(pageKey);
      if (mounted) {
        if (data.isLastPage) {
          controller.appendLastPage(data.list);
        } else {
          controller.appendPage(data.list, data.currentPage + 1);
        }
      }
    } catch (error) {
      if (mounted) {
        controller.error = error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: PagedListView<int, T>.separated(
        pagingController: controller,
        padding: widget.padding,
        builderDelegate: PagedChildBuilderDelegate<T>(
          itemBuilder: (_, T t, int i) => widget.itemBuilder(t, i),
          noItemsFoundIndicatorBuilder: (_) =>
              Center(child: widget.noItemWidget),
          firstPageErrorIndicatorBuilder: (_) => CustomErrorWidget(
            error: kDebugMode
                ? controller.error.toString()
                : context.locale.errorMessage,
            onTap: controller.refresh,
          ),
          firstPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
          newPageErrorIndicatorBuilder: (_) => Center(
            child: GestureDetector(
              onTap: controller.retryLastFailedRequest,
              child: Text(
                locale.tryAgain,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          newPageProgressIndicatorBuilder: (_) => const UnconstrainedBox(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        separatorBuilder: (_, __) =>
            widget.sepratedWidget ?? const SizedBox(height: 12),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }
}

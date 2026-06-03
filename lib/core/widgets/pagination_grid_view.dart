import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../models/pagination_model.dart';

class PaginationGridView<T> extends ConsumerStatefulWidget {
  final PagingController<int, T>? controller;
  final Future<PaginationModel<T>> Function(int) getList;
  final Widget Function(T, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final Widget noItemWidget;
  final SliverGridDelegate gridDelegate;

  const PaginationGridView({
    super.key,
    this.controller,
    required this.getList,
    required this.itemBuilder,
    required this.noItemWidget,
    required this.gridDelegate,
    this.padding,
  });

  @override
  ConsumerState<PaginationGridView<T>> createState() =>
      _PaginationGridViewState<T>();
}

class _PaginationGridViewState<T> extends ConsumerState<PaginationGridView<T>> {
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
      child: PagedGridView<int, T>(
        pagingController: controller,
        padding: widget.padding,
        gridDelegate: widget.gridDelegate,
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

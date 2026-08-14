import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/administrative_actions/data/models/administrative_action_model.dart';
import 'package:smart_table_app/features/administrative_actions/presentation/views/administrative_action_form_view.dart';
import 'package:smart_table_app/features/administrative_actions/providers/administrative_actions_provider.dart';

class AdministrativeActionsView extends ConsumerWidget {
  const AdministrativeActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(administrativeActionsProvider);

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
          title: const Text(
            'الإجراءات الإدارية',
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: actions.when(
          data: (page) => _ActionsContent(
            actions: page.results,
            onActionSelected: (action) => _openAction(context, action),
          ),
          loading: () => const Center(child: LoadingWidget()),
          error: (error, _) => CustomErrorWidget(
            error: error is Exception
                ? exceptionHandler(context: context, exception: error)
                : null,
            onTap: () => ref.invalidate(administrativeActionsProvider),
          ),
        ),
      ),
    );
  }

  Future<void> _openAction(
    BuildContext context,
    AdministrativeActionModel action,
  ) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdministrativeActionFormView(action: action),
      ),
    );
    if (submitted == true && context.mounted) {
      context.showSnackbarSuccess('تم إرسال الإجراء للمدير بنجاح');
    }
  }
}

class _ActionsContent extends StatelessWidget {
  const _ActionsContent({
    required this.actions,
    required this.onActionSelected,
  });

  final List<AdministrativeActionModel> actions;
  final ValueChanged<AdministrativeActionModel> onActionSelected;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const _EmptyActionsState();
    final showNotice = actions.any((action) => action.needsAction);
    final leadingCount = showNotice ? 1 : 0;

    return RefreshIndicator(
      onRefresh: () async {
        final container = ProviderScope.containerOf(context);
        container.invalidate(administrativeActionsProvider);
        await container.read(administrativeActionsProvider.future);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        itemCount: actions.length + leadingCount,
        separatorBuilder: (_, index) =>
            SizedBox(height: showNotice && index == 0 ? 20 : 14),
        itemBuilder: (context, index) {
          if (showNotice && index == 0) {
            return const _AdministrativeActionsNotice();
          }
          final action = actions[index - leadingCount];
          return _AdministrativeActionCard(
            action: action,
            onTap: () => onActionSelected(action),
          );
        },
      ),
    );
  }
}

class _AdministrativeActionsNotice extends StatelessWidget {
  const _AdministrativeActionsNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFFF3038), width: 1.3),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFF202D),
            size: 31,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'يرجى استكمال البيانات المطلوبة للإجراء الإداري\nوإرسالها للمدير',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFF202D),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdministrativeActionCard extends StatelessWidget {
  const _AdministrativeActionCard({
    required this.action,
    required this.onTap,
  });

  final AdministrativeActionModel action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 104),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const _ActionInformationIcon(),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action.date,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (action.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          action.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF565656),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    key: ValueKey('administrative-action-chevron'),
                    color: AppColors.primaryColor,
                    size: 28,
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

class _ActionInformationIcon extends StatelessWidget {
  const _ActionInformationIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 53,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            child: Container(
              width: 42,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryColor,
                size: 28,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Container(
              width: 43,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActionsState extends StatelessWidget {
  const _EmptyActionsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryColor,
            size: 58,
          ),
          SizedBox(height: 16),
          Text(
            'لا يوجد بيانات للعرض',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

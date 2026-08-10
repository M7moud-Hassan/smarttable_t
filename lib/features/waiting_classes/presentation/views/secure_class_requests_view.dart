import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/confirm_dialog_widget.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/waiting_classes/data/models/secure_class_request_model.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_notifier.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_provider.dart';

class SecureClassRequestsView extends StatelessWidget {
  const SecureClassRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(
            color: AppColors.primaryColor,
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'طلبات تأمين الحصص',
            style: TextStyle(
              color: AppColors.secondryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.secondryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'طلباتي'),
              Tab(text: 'الطلبات المستلمة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RequestsTab(role: 'made'),
            _RequestsTab(role: 'received'),
          ],
        ),
      ),
    );
  }
}

class _RequestsTab extends ConsumerStatefulWidget {
  const _RequestsTab({required this.role});

  final String role;

  @override
  ConsumerState<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends ConsumerState<_RequestsTab> {
  String? _status;

  SecureClassRequestsQuery get _query => (
        role: widget.role,
        status: _status,
      );

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(secureClassRequestsProvider(_query));

    return Column(
      children: [
        _StatusFilter(
          selectedStatus: _status,
          onSelected: (status) => setState(() => _status = status),
        ),
        Expanded(
          child: requestsAsync.when(
            data: (requests) => RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () =>
                  ref.refresh(secureClassRequestsProvider(_query).future),
              child: requests.isEmpty
                  ? const _EmptyRequestsView()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _RequestCard(
                        request: requests[index],
                        role: widget.role,
                        onCancel:
                            widget.role == 'made' && requests[index].canCancel
                                ? () => _confirmCancellation(requests[index])
                                : null,
                      ),
                    ),
            ),
            loading: () => const Center(child: LoadingWidget()),
            error: (error, stackTrace) => CustomErrorWidget(
              error: error.toString(),
              onTap: () => ref.invalidate(
                secureClassRequestsProvider(_query),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmCancellation(SecureClassRequestModel request) {
    showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialogWidget(
        title:
            'هل تريد إلغاء هذا الطلب؟ لا يمكن إلغاء الطلب بعد اعتماد الإدارة.',
        onConfirm: () {
          ref
              .read(waitingClassNotifierProvider.notifier)
              .cancelSecureClassRequest(request.id);
        },
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.selectedStatus,
    required this.onSelected,
  });

  final String? selectedStatus;
  final ValueChanged<String?> onSelected;

  static const statuses = <(String?, String)>[
    (null, 'الكل'),
    ('pending', 'قيد الانتظار'),
    ('confirmed', 'مؤكد'),
    ('rejected', 'مرفوض'),
    ('cancelled', 'ملغي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final status in statuses) ...[
              ChoiceChip(
                label: Text(status.$2),
                selected: selectedStatus == status.$1,
                selectedColor: AppColors.primaryColor.withValues(alpha: 0.18),
                side: BorderSide(
                  color: selectedStatus == status.$1
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
                labelStyle: TextStyle(
                  color: selectedStatus == status.$1
                      ? AppColors.secondryColor
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => onSelected(status.$1),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.role,
    this.onCancel,
  });

  final SecureClassRequestModel request;
  final String role;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final lesson = request.lesson;
    final counterpart =
        role == 'made' ? request.substituteName : request.applicantName;
    final counterpartLabel = role == 'made' ? 'المعلم البديل' : 'مقدم الطلب';
    final lessonMeta = [
      lesson.dayName,
      lesson.classNumberText,
      lesson.classroom,
    ].where((value) => value.isNotEmpty).join(' • ');
    final time = [lesson.startTime, lesson.endTime]
        .where((value) => value.isNotEmpty)
        .join(' - ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.subject.isEmpty ? 'حصة دراسية' : lesson.subject,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1E3A5F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.statusText.isEmpty
                        ? _statusLabel(request.status)
                        : request.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (lessonMeta.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoLine(icon: Icons.event_note_rounded, text: lessonMeta),
            ],
            if (time.isNotEmpty) ...[
              const SizedBox(height: 7),
              _InfoLine(icon: Icons.schedule_rounded, text: time),
            ],
            if (request.date.isNotEmpty) ...[
              const SizedBox(height: 7),
              _InfoLine(icon: Icons.calendar_today_rounded, text: request.date),
            ],
            const SizedBox(height: 10),
            Text(
              '$counterpartLabel: ${counterpart.isEmpty ? 'غير محدد' : counterpart}',
              style: const TextStyle(
                color: AppColors.secondryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('ملاحظتك: ${request.note}'),
            ],
            if (request.managerNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'ملاحظة الإدارة: ${request.managerNote}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('إلغاء الطلب'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

class _EmptyRequestsView extends StatelessWidget {
  const _EmptyRequestsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 110),
        Icon(
          Icons.assignment_outlined,
          size: 72,
          color: AppColors.primaryColor,
        ),
        SizedBox(height: 18),
        Text(
          'لا توجد طلبات',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'confirmed':
      return const Color(0xFF27966A);
    case 'rejected':
      return const Color(0xFFC44738);
    case 'cancelled':
      return Colors.grey;
    default:
      return const Color(0xFFB7791F);
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'confirmed':
      return 'مؤكد';
    case 'rejected':
      return 'مرفوض';
    case 'cancelled':
      return 'ملغي';
    default:
      return 'قيد الانتظار';
  }
}

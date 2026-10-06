import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/widgets/sliding_dropdown.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class AttendanceBehaviorFilterSheet extends ConsumerStatefulWidget {
  const AttendanceBehaviorFilterSheet({super.key});

  @override
  ConsumerState<AttendanceBehaviorFilterSheet> createState() =>
      _AttendanceBehaviorFilterSheetState();
}

class _AttendanceBehaviorFilterSheetState
    extends ConsumerState<AttendanceBehaviorFilterSheet> {
  int? _classId;
  String? _session;
  String? _date;

  @override
  void initState() {
    super.initState();
    final state = ref.read(attendanceBehaviorProvider);
    _classId = state.selectedClassId;
    _session = state.selectedSession;
    _date = state.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final featureState = ref.watch(attendanceBehaviorProvider);
    final filters = featureState.filters;
    final classes =
        filters?.classes.where((item) => item.id != null).toList() ?? const [];
    final sessions = filters?.sessions ?? const [];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'فلترة القائمة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              SlidingDropdown<int>(
                value: classes.any((item) => item.id == _classId)
                    ? _classId
                    : null,
                menuMaxHeight: 200,
                decoration: const InputDecoration(
                  labelText: 'الفصل',
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          item.studentsCount > 0
                              ? '${item.name} (${item.studentsCount})'
                              : item.name,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _classId = value),
              ),
              const SizedBox(height: 14),
              SlidingDropdown<String>(
                value: sessions.any((item) => item.value == _session)
                    ? _session
                    : null,
                menuMaxHeight: 180,
                decoration: const InputDecoration(
                  labelText: 'الحصة',
                  border: OutlineInputBorder(),
                ),
                items: sessions
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.value,
                        child: Text(item.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _session = value),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(_date?.isNotEmpty == true ? _date! : 'تاريخ اليوم'),
                onPressed: _pickDate,
              ),
              const SizedBox(height: 20),
              PrimaryActionButton(
                label: featureState.loading ? 'جارٍ التحميل...' : 'تطبيق',
                onPressed: _classId == null ||
                        _session == null ||
                        featureState.loading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(attendanceBehaviorProvider.notifier)
                              .changeContext(
                                classId: _classId!,
                                session: _session!,
                                date: _date,
                              );
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(perseveranceErrorMessage(error)),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_date ?? '') ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null) return;
    setState(() {
      _date = '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    });
  }
}

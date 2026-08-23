import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class BehaviorNotesView extends ConsumerStatefulWidget {
  const BehaviorNotesView({super.key});

  @override
  ConsumerState<BehaviorNotesView> createState() => _BehaviorNotesViewState();
}

class _BehaviorNotesViewState extends ConsumerState<BehaviorNotesView> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final featureState = ref.watch(attendanceBehaviorProvider);
    final notes = featureState.behaviorNotes.where(
      (note) {
        if (_filter == 1) return note.type == BehaviorNoteType.positive;
        if (_filter == 2) {
          return note.type == BehaviorNoteType.needsImprovement;
        }
        return true;
      },
    ).toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: FeatureTitleAppBar(
          title: 'قائمة ملاحظات السلوك',
          action: IconButton.filled(
            tooltip: 'إضافة ملاحظة جديدة',
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: FeatureSegmentedControl(
                labels: const ['الكل', 'إيجابي', 'بحاجة إلى تحسين'],
                selectedIndex: _filter,
                onSelected: (index) => setState(() => _filter = index),
              ),
            ),
            Expanded(
              child: featureState.loading && notes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 13),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _BehaviorNoteCard(
                          note: note,
                          onEdit: () => _openForm(context, note),
                          onDelete: () => _delete(context, note),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, [
    BehaviorNoteModel? note,
  ]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => BehaviorNoteFormView(note: note)),
    );
  }

  Future<void> _delete(
    BuildContext context,
    BehaviorNoteModel note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الملاحظة'),
        content: Text('هل تريد حذف ملاحظة "${note.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'حذف',
              style: TextStyle(color: attendanceRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(attendanceBehaviorProvider.notifier)
            .deleteBehaviorNote(note.id);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(perseveranceErrorMessage(error))),
        );
      }
    }
  }
}

class _BehaviorNoteCard extends StatelessWidget {
  const _BehaviorNoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final BehaviorNoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = behaviorNoteColor(note);
    return Material(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: .18),
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 48,
              alignment: Alignment.center,
              color: color,
              child: Text(
                '${note.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8ED),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                behaviorIcon(note.iconKey),
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${note.points} نقاط',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (note.usageCount > 0)
                      Text(
                        'مستخدمة ${note.usageCount} مرة',
                        style: const TextStyle(fontSize: 11),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'تعديل',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primaryColor,
            ),
            IconButton(
              tooltip: 'حذف',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: attendanceRed,
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}

class BehaviorNoteFormView extends ConsumerStatefulWidget {
  const BehaviorNoteFormView({super.key, this.note});

  final BehaviorNoteModel? note;

  @override
  ConsumerState<BehaviorNoteFormView> createState() =>
      _BehaviorNoteFormViewState();
}

class _BehaviorNoteFormViewState extends ConsumerState<BehaviorNoteFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _points;
  late BehaviorNoteType _type;
  late String _iconKey;

  static const _icons = ['smile', 'sad', 'star', 'like', 'warning'];

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _nameController = TextEditingController(text: note?.name ?? '');
    _points = note?.points ?? -1;
    _type = note?.type ?? BehaviorNoteType.needsImprovement;
    _iconKey = note?.iconKey ?? 'like';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: FeatureTitleAppBar(
          title: widget.note == null
              ? 'إضافة ملاحظة سلوك جديدة'
              : 'تعديل ملاحظة السلوك',
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              const _FieldLabel('اسم الملاحظة'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('أدخل اسم الملاحظة'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'أدخل اسم الملاحظة'
                    : null,
              ),
              const SizedBox(height: 20),
              const _FieldLabel('النقاط'),
              DropdownButtonFormField<int>(
                initialValue: _points,
                decoration: _inputDecoration('اختر النقاط'),
                items: ({-10, -5, -1, 0, 1, 5, 10, _points}.toList()..sort())
                    .map(
                      (points) => DropdownMenuItem(
                        value: points,
                        child: Text('$points'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _points = value!),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('نوع الملاحظة'),
              DropdownButtonFormField<BehaviorNoteType>(
                initialValue: _type,
                decoration: _inputDecoration('اختر نوع الملاحظة'),
                items: BehaviorNoteType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('الأيقونة'),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8,
                  children: _icons.map((iconKey) {
                    final selected = iconKey == _iconKey;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _iconKey = iconKey),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryColor.withValues(alpha: .14)
                              : Colors.transparent,
                          border: selected
                              ? Border.all(color: AppColors.primaryColor)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          behaviorIcon(iconKey),
                          color:
                              selected ? AppColors.secondryColor : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
              const SizedBox(height: 34),
              PrimaryActionButton(
                label: 'حفظ',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(attendanceBehaviorProvider.notifier);
    final existing = widget.note;
    final edited = (existing ??
            BehaviorNoteModel(
              id: 0,
              name: _nameController.text.trim(),
              points: _points,
              type: _type,
              iconKey: _iconKey,
            ))
        .copyWith(
      name: _nameController.text.trim(),
      points: _points,
      type: _type,
      iconKey: _iconKey,
    );
    try {
      if (existing == null) {
        await notifier.createBehaviorNote(edited);
      } else {
        await notifier.updateBehaviorNote(edited);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );
  }
}

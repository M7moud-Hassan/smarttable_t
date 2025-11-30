import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/master_table_model.dart';

import '../data/repositories/school_table_repo.dart';
import 'days_provider.dart';

final masterTableProvider =
    FutureProvider.autoDispose<MasterTableModel>((ref) async {
  final dayId = ref.watch(selectedDayProvider);
  return ref.read(schoolTableRepoProvider).getMasterTable(dayId);
});

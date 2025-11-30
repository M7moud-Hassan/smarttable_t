import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/day_model.dart';
import 'package:smart_table_app/features/school_table/data/repositories/school_table_repo.dart';

final daysProvider = FutureProvider<List<DayModel>>((ref) async {
  return ref.read(schoolTableRepoProvider).getDays();
});

final selectedDayProvider = StateProvider<int>((ref) {
  final days = ref.watch(daysProvider);
  if (days.hasValue) {
    final daysValue = days.value!;
    final currentDayIndex =
        daysValue.indexWhere((element) => element.isCurrent);
    if (currentDayIndex != -1) {
      return daysValue[currentDayIndex].dayId;
    }
  }
  return 0;
});

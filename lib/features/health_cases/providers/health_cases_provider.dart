import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/features/health_cases/data/models/health_case_details_model.dart';
import 'package:smart_table_app/features/health_cases/data/models/health_case_model.dart';
import 'package:smart_table_app/features/health_cases/data/repositories/health_cases_repo.dart';

final healthCasesListProvider = FutureProvider.autoDispose
    .family<PaginationModel<HealthCaseModel>, int>((ref, page) async {
  return ref.read(healthCasesRepoProvider).getHealthCases(page);
});

final currentHealthCaseProvider = Provider<HealthCaseModel>((ref) {
  throw UnimplementedError();
});

final healthCasesDetailsProvider =
    FutureProvider.autoDispose<List<HealthCaseDetailsModel>>((ref) async {
  final id = ref.watch(currentHealthCaseProvider).id;
  return ref.read(healthCasesRepoProvider).getHealthCasesDetails(id);
}, dependencies: [currentHealthCaseProvider]);

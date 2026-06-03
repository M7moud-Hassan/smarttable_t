import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/performance_evidence/data/models/performance_evidence_model.dart';
import 'package:smart_table_app/features/performance_evidence/data/repositories/performance_evidence_repository.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/features/performance_evidence/data/models/performance_evidence_model.dart';
import 'package:smart_table_app/features/performance_evidence/data/repositories/performance_evidence_repository.dart';

final performanceEvidenceProvider =
    StateNotifierProvider<PerformanceEvidenceNotifier, AsyncValue<void>>(
  (ref) => PerformanceEvidenceNotifier(ref),
);

class PerformanceEvidenceNotifier extends StateNotifier<AsyncValue<void>> {
  PerformanceEvidenceNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;
  final PagingController<int, PerformanceEvidenceModel> pagingController =
      PagingController(firstPageKey: 1);

  List<PerformanceEvidenceModel> _allEvidences = [];

  Future<PaginationModel<PerformanceEvidenceModel>> getEvidences(int page) async {
    final response =
        await ref.read(performanceEvidenceRepoProvider).getEvidences(page);
    if (page == 1) {
      _allEvidences = response.list;
    } else {
      _allEvidences.addAll(response.list);
    }
    return response;
  }

  void filterEvidences(String query) {
    if (query.isEmpty) {
      pagingController.itemList = _allEvidences;
    } else {
      pagingController.itemList = _allEvidences
          .where((item) =>
              (item.title ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (item.category?.name ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<bool> addEvidence({
    required int categoryId,
    required String typeFile,
    required File file,
  }) async {
    final success = await ref.read(performanceEvidenceRepoProvider).addEvidence(
          categoryId: categoryId,
          typeFile: typeFile,
          file: file,
        );
    if (success) {
      pagingController.refresh();
    }
    return success;
  }

  Future<bool> deleteEvidence(int id) async {
    final success =
        await ref.read(performanceEvidenceRepoProvider).deleteEvidence(id);
    if (success) {
      _allEvidences.removeWhere((e) => e.id == id);
      pagingController.itemList =
          pagingController.itemList?.where((e) => e.id != id).toList();
    }
    return success;
  }
}

final evidenceCategoriesProvider =
    FutureProvider<List<EvidenceCategoryModel>>((ref) {
  return ref.watch(performanceEvidenceRepoProvider).getCategories();
});

final performanceEvidenceSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPerformanceEvidenceProvider =
    Provider<AsyncValue<void>>((ref) {
  return ref.watch(performanceEvidenceProvider);
});

import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/performance_evidence/data/models/performance_evidence_model.dart';

final performanceEvidenceRepoProvider = Provider<PerformanceEvidenceRepository>((ref) {
  return PerformanceEvidenceRepository(ref);
});

class PerformanceEvidenceRepository {
  final Ref _ref;
  final ApiService _apiService;

  PerformanceEvidenceRepository(this._ref)
      : _apiService = _ref.read(apiServiceProvider);

  Future<PaginationModel<PerformanceEvidenceModel>> getEvidences(
      int page) async {
    final response = await _apiService.get(
      Endpoints.performanceEvidence,
      parameters: {'page': page},
    );
    final pagination = PaginationModel<PerformanceEvidenceModel>();
    pagination.setData(
      map: response.data,
      fromJson: PerformanceEvidenceModel.fromJson,
    );
    return pagination;
  }

  Future<List<EvidenceCategoryModel>> getCategories() async {
    final response = await _apiService.get(Endpoints.performanceEvidenceCategories);
    if (response.success ?? false) {
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((e) => EvidenceCategoryModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> addEvidence({
    required int categoryId,
    required String typeFile,
    required File file,
  }) async {
    final response = await _apiService.multipartRequest(
      Endpoints.performanceEvidence,
      {
        'category_id': categoryId.toString(),
        'type_file': typeFile,
      },
      {'file': file},
    );
    return response.success ?? false;
  }

  Future<bool> deleteEvidence(int id) async {
    final response = await _apiService.delete('${Endpoints.performanceEvidence}$id/');
    return response.success ?? false;
  }
}

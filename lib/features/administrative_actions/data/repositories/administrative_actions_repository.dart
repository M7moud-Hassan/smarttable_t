import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/administrative_actions/data/models/administrative_action_model.dart';

final administrativeActionsRepositoryProvider =
    Provider<AdministrativeActionsRepository>((ref) {
  return ApiAdministrativeActionsRepository(ref.read(apiServiceProvider));
});

abstract class AdministrativeActionsRepository {
  Future<AdministrativeActionsPage> getProcedures({
    int page = 1,
    int pageSize = 100,
  });

  Future<AdministrativeActionDetailModel> getProcedure(
    AdministrativeProcedureKey key,
  );

  Future<void> submitTeacherReason(
    AdministrativeProcedureKey key,
    String teacherReason,
  );
}

class ApiAdministrativeActionsRepository
    implements AdministrativeActionsRepository {
  ApiAdministrativeActionsRepository(this._apiService);

  final ApiService _apiService;

  @override
  Future<AdministrativeActionsPage> getProcedures({
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await _apiService.get(
      Endpoints.administrativeProcedures,
      parameters: {'page': page, 'page_size': pageSize},
    );
    _ensureSuccess(response.success, response.message);
    final data = response.data;
    if (data is List) {
      return AdministrativeActionsPage.fromJson({
        'count': data.length,
        'next': null,
        'previous': null,
        'results': data,
      });
    }
    return AdministrativeActionsPage.fromJson(_asMap(data));
  }

  @override
  Future<AdministrativeActionDetailModel> getProcedure(
    AdministrativeProcedureKey key,
  ) async {
    final response = await _apiService.get(
      Endpoints.administrativeProcedure(key.procedureType, key.id),
    );
    _ensureSuccess(response.success, response.message);
    return AdministrativeActionDetailModel.fromJson(_asMap(response.data));
  }

  @override
  Future<void> submitTeacherReason(
    AdministrativeProcedureKey key,
    String teacherReason,
  ) async {
    final response = await _apiService.patch(
      Endpoints.administrativeProcedure(key.procedureType, key.id),
      // The detail response exposes this value as `teacher_reason`, while the
      // endpoint's write serializer validates it under `reason`.
      {'reason': teacherReason.trim()},
    );
    _ensureSuccess(response.success, response.message);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ServerException(null);
  }

  void _ensureSuccess(bool? success, String? message) {
    if (success != true) throw ServerException(message);
  }
}

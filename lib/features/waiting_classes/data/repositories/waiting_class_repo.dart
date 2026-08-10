import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../school_table/data/models/lesson_model.dart';
import '../models/secure_class_request_model.dart';
import '../models/substitute_model.dart';

final waitingClasessRepoProvider = Provider<WaitingClasessRepository>((ref) {
  return WaitingClasessRepository(ref);
});

class WaitingClasessRepository {
  final Ref<WaitingClasessRepository> ref;
  final ApiService _apiService;

  WaitingClasessRepository(this.ref)
      : _apiService = ref.read(apiServiceProvider);

  Future<List<LessonModel>> getWaitingClasess() async {
    final response = await _apiService.get(
      Endpoints.waitingClasses,
    );
    return List<LessonModel>.from(
        response.data.map((x) => LessonModel.fromJson(x)));
  }

  Future<List<SubstituteModel>> getSubstituteTeachers(int cellNumber,
      {bool? availableOnly}) async {
    final Map<String, dynamic> params = {};
    if (availableOnly != null) {
      params['available_only'] = availableOnly.toString();
    }
    final response = await _apiService.get(
      Endpoints.secureClassSubstitutes(cellNumber),
      parameters: params.isNotEmpty ? params : null,
    );

    if (response.success != true) {
      throw ServerException(response.message ?? '');
    }

    final responseData = response.data;
    final List<dynamic> list = responseData is List
        ? responseData
        : responseData is Map
            ? (responseData['substitutes'] ?? responseData['data'] ?? [])
                as List<dynamic>
            : const [];
    return List<SubstituteModel>.from(
        list.map((x) => SubstituteModel.fromJson(x)));
  }

  Future<void> createSecureClassRequest(
      int cellNumber, int substituteId, String? note) async {
    final response = await _apiService.post(Endpoints.secureClassRequests, {
      'cell_number': cellNumber,
      'substitute_id': substituteId,
      if (note != null && note.isNotEmpty) 'note': note,
    });

    if (response.success!) {
      return;
    }

    String errorMsg = '';
    if (response.data is Map && response.data['detail'] != null) {
      errorMsg = response.data['detail'].toString();
    } else {
      errorMsg = response.message ?? '';
    }
    throw ServerException(errorMsg);
  }

  Future<List<SecureClassRequestModel>> getSecureClassRequests({
    String role = 'made',
    String? status,
  }) async {
    final response = await _apiService.get(
      Endpoints.secureClassRequests,
      parameters: {
        'role': role,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    if (response.success != true) {
      throw ServerException(response.message ?? '');
    }

    final responseData = response.data;
    final list = responseData is List
        ? responseData
        : responseData is Map && responseData['data'] is List
            ? responseData['data'] as List
            : const <dynamic>[];

    return list
        .whereType<Map>()
        .map((item) => SecureClassRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList(growable: false);
  }

  Future<String?> cancelSecureClassRequest(int requestId) async {
    final response = await _apiService.delete(
      Endpoints.secureClassRequest(requestId),
    );

    if (response.success != true) {
      throw ServerException(response.message ?? '');
    }

    return response.message;
  }
}

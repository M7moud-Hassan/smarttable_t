
import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/exams/data/models/exam_hall_group_model.dart';
import 'package:smart_table_app/features/exams/data/models/exam_hall_model.dart';
import 'package:smart_table_app/features/notifications/data/models/notifications_model.dart';
import 'package:smart_table_app/features/circulars/data/models/circulars_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';

final examHallsRepoProvider = Provider<ExamHallsRepository>((ref) {
  return ExamHallsRepository(ref);
});

class ExamHallsRepository {
  final Ref<ExamHallsRepository> ref;
  final ApiService _apiService;

  ExamHallsRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<ExamHallGroupModel>> getExamHallsGroups(
    int page,
  ) async {
    final response = await _apiService.get(
      Endpoints.examHalls,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<ExamHallGroupModel>();
    pagination.setData(
        map: response.data, fromJson: ExamHallGroupModel.fromJson);
    return pagination;
  }

  Future<List<ExamHallModel>> getExamHalls(
    int id,
  ) async {
    final response = await _apiService.get(
      '${Endpoints.examHalls}$id/',
    );

    return List<ExamHallModel>.from(
        response.data['results'].map((x) => ExamHallModel.fromJson(x)));
  }
}

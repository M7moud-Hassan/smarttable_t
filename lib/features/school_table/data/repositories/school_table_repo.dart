import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/school_table/data/models/day_model.dart';
import 'package:smart_table_app/features/school_table/data/models/teacher_table_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../models/master_table_model.dart';

final schoolTableRepoProvider = Provider<SchoolTableRepository>((ref) {
  return SchoolTableRepository(ref);
});

class SchoolTableRepository {
  final Ref<SchoolTableRepository> ref;
  final ApiService _apiService;

  SchoolTableRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<MasterTableModel> getMasterTable(int dayId) async {
    final response = await _apiService.get(
      '${Endpoints.masterTable}$dayId',
    );
    return MasterTableModel.fromJson(response.data);
  }

  Future<TeacherTableModel> getTeacherTable() async {
    final response = await _apiService.get(
      Endpoints.teacherTable,
    );
    return TeacherTableModel.fromJson(response.data);
  }

  Future<List<DayModel>> getDays() async {
    final response = await _apiService.get(
      Endpoints.days,
    );
    return List<DayModel>.from(response.data.map((x) => DayModel.fromJson(x)));
  }
}

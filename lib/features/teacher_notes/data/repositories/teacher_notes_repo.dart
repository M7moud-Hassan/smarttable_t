import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/teacher_notes/data/models/teacher_note_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';

final teacherNotesRepoProvider = Provider<TeacherNotesRepository>((ref) {
  return TeacherNotesRepository(ref);
});

class TeacherNotesRepository {
  final Ref<TeacherNotesRepository> ref;
  final ApiService _apiService;

  TeacherNotesRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<TeacherNoteModel>> getTeacherNotes(int page) async {
    final response = await _apiService.get(
      Endpoints.teacherNotes,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<TeacherNoteModel>();
    pagination.setData(map: response.data, fromJson: TeacherNoteModel.fromJson);
    return pagination;
  }
}

import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/utils/exceptions.dart';
import '../models/week_info_model.dart';
import '../models/weekly_plan_model.dart';

final weeklyPlanRepoProvider = Provider<WeeklyPlanRepository>((ref) {
  return WeeklyPlanRepository(ref);
});

class WeeklyPlanRepository {
  final Ref<WeeklyPlanRepository> ref;
  final ApiService _apiService;

  WeeklyPlanRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<WeeklyPlanModel>> getWeeklyPlanList() async {
    final response = await _apiService.get(
      Endpoints.weekPlan,
    );
    final pagination = PaginationModel<WeeklyPlanModel>();
    pagination.setData(
      map: response.data,
      fromJson: WeeklyPlanModel.fromJson,
    );
    return pagination;
  }

  Future<void> deleteWeeklyPlan(int id) async {
    final response = await _apiService.delete(
      '${Endpoints.weekPlan}$id/',
    );
    if (!response.success!) {
      throw ServerException(null);
    }
  }

  Future<void> updateWeeklyPlan(File file, int weekId) async {
    final response = await _apiService.multipartRequest(
      Endpoints.weekPlan,
      {'week_info': weekId.toString()},
      {
        'file': file,
      },
    );
    if (response.success == false) {
      throw ServerException(null);
    }
  }

  Future<PaginationModel<WeekInfoModel>> getWeeksList(int page) async {
    final response = await _apiService.get(
      Endpoints.weekInfo,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<WeekInfoModel>();
    pagination.setData(
      map: response.data,
      fromJson: WeekInfoModel.fromJson,
    );
    return pagination;
  }
}

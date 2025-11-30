import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/home/data/models/home_data_model.dart';
import 'package:smart_table_app/features/home/data/repositories/home_repo.dart';

final homeMenuProvider = FutureProvider<HomeDataModel>((ref) async {
  return ref.read(homeRepoProvider).getHomeMenues();
});

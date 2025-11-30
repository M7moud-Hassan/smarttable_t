import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/profile/data/models/profile_model.dart';
import 'package:smart_table_app/features/profile/data/repositories/profile_repo.dart';

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  return ref.read(profileRepoProvider).getProfile();
});

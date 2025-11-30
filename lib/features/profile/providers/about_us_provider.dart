import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/profile/data/repositories/profile_repo.dart';

final aboutUsProvider = FutureProvider.autoDispose<String>((ref) async {
  return ref.read(profileRepoProvider).aboutUs();
});

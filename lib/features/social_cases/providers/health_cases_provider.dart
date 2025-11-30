import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/models/pagination_model.dart';
import '../data/models/social_cases_details_model.dart';
import '../data/models/social_cases_model.dart';
import '../data/repositories/social_cases_repo.dart';

final socialCasesListProvider = FutureProvider.autoDispose
    .family<PaginationModel<SocialCaseModel>, int>((ref, page) async {
  return ref.read(socialCaseRepoProvider).getSocialCases(page);
});

final currentSocialCaseProvider = Provider<SocialCaseModel>((ref) {
  throw UnimplementedError();
});

final socialCasesDetailsProvider =
    FutureProvider.autoDispose<List<SocialCaseDetailsModel>>((ref) async {
  final id = ref.watch(currentSocialCaseProvider).id;
  return ref.read(socialCaseRepoProvider).getSocialCasesDetails(id);
}, dependencies: [currentSocialCaseProvider]);

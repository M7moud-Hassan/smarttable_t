import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/keys_enums.dart';
import 'package:smart_table_app/core/models/request_response_state_model.dart';
import 'package:smart_table_app/core/providers/request_response_provider.dart';
import 'package:smart_table_app/features/profile/data/models/profile_model.dart';
import 'package:smart_table_app/features/profile/data/repositories/profile_repo.dart';

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  return ref.read(profileRepoProvider).getProfile();
});

final profilePhotoProvider = FutureProvider.autoDispose<String?>((ref) async {
  return ref.read(profileRepoProvider).getProfilePhoto();
});

final signatureProvider = FutureProvider.autoDispose<String?>((ref) async {
  return ref.read(profileRepoProvider).getSignature();
});

class ProfilePhotoNotifier extends StateNotifier<bool> {
  ProfilePhotoNotifier(this._ref) : super(false);
  final Ref _ref;

  Future<bool> saveProfilePhoto(File file) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());

      final response =
          await _ref.read(profileRepoProvider).uploadProfilePhoto(file);

      if (response.success ?? false) {
        _ref.invalidate(profilePhotoProvider);
        _ref.read(requestResponseProvider.notifier).update(
              (state) => RequestResponseModel.success(
                actionOnDone: ActionOnDone.none,
                message: response.message,
              ),
            );
        return true;
      }

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(message: response.message),
          );
      return false;
    } on Exception catch (e) {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
      return false;
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }

  Future<bool> deleteProfilePhoto() async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());

      final success = await _ref.read(profileRepoProvider).deleteProfilePhoto();

      if (success) {
        _ref.invalidate(profilePhotoProvider);
        _ref.read(requestResponseProvider.notifier).update(
              (state) => RequestResponseModel.success(
                actionOnDone: ActionOnDone.none,
              ),
            );
        return true;
      }

      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error());
      return false;
    } on Exception catch (e) {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
      return false;
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }
}

final profilePhotoNotifierProvider =
    StateNotifierProvider.autoDispose<ProfilePhotoNotifier, bool>((ref) {
  return ProfilePhotoNotifier(ref);
});

class TeacherSignatureNotifier extends StateNotifier<bool> {
  TeacherSignatureNotifier(this._ref) : super(false);
  final Ref _ref;

  Future<bool> saveSignature(File file) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());

      final response =
          await _ref.read(profileRepoProvider).uploadSignature(file);

      if (response.success ?? false) {
        _ref.invalidate(signatureProvider);
        _ref.read(requestResponseProvider.notifier).update((state) =>
            RequestResponseModel.success(
                actionOnDone: ActionOnDone.none, message: response.message));
        return true;
      } else {
        _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(message: response.message));
        return false;
      }
    } on Exception catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error(exception: e));
      return false;
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }

  Future<bool> deleteSignature() async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());

      final success = await _ref.read(profileRepoProvider).deleteSignature();

      if (success) {
        _ref.invalidate(signatureProvider);
        _ref.read(requestResponseProvider.notifier).update((state) =>
            RequestResponseModel.success(actionOnDone: ActionOnDone.none));
        return true;
      } else {
        _ref
            .read(requestResponseProvider.notifier)
            .update((state) => RequestResponseModel.error());
        return false;
      }
    } on Exception catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error(exception: e));
      return false;
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }
}

final teacherSignatureNotifierProvider =
    StateNotifierProvider.autoDispose<TeacherSignatureNotifier, bool>((ref) {
  return TeacherSignatureNotifier(ref);
});

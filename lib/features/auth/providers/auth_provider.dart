import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/providers/request_response_provider.dart';
import 'package:smart_table_app/core/utils/token_storage.dart';
import 'package:smart_table_app/features/auth/data/repositories/auth_repo.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../core/models/models.dart';
import '../../profile/providers/profile_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(AuthState.init);

  final Ref _ref;

  Future<void> registerTeacher(
      String usercode, String username, String password, String email) async {
    try {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(),
          );

      final response = await _ref
          .read(authRepoProvider)
          .teacherRegisterData(usercode, username, password, email);
      _ref.read(tokenStorageProvider).saveToken(response.token!);

      await _ref.read(authRepoProvider).updateFcm();
      _ref.read(profileProvider);

      state = AuthState.auth;

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              actionOnDone: ActionOnDone.registerSucess,
            ),
          );
    } on Exception catch (e, s) {
      // 🔥 log to Crashlytics
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'registerTeacher failed',
        information: [
          {'usercode': usercode, 'username': username, 'email': email},
        ],
      );

      // ✅ keep your old logic
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
    } finally {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(loading: false),
          );
    }
  }

  Future<void> registerTeacherByPhone(
      String phone, String username, String password, String email) async {
    try {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(),
          );

      final response = await _ref
          .read(authRepoProvider)
          .teacherRegisterDataByPhone(phone, username, password, email);
      _ref.read(tokenStorageProvider).saveToken(response.token!);

      await _ref.read(authRepoProvider).updateFcm();
      _ref.read(profileProvider);

      state = AuthState.auth;

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              actionOnDone: ActionOnDone.registerSucess,
            ),
          );
    } on Exception catch (e, s) {
      // 🔥 log to Crashlytics
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'registerTeacher failed',
        information: [
          {'phone': phone, 'username': username, 'email': email},
        ],
      );

      // ✅ keep your old logic
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
    } finally {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(loading: false),
          );
    }
  }

  Future<void> idCodeRegisterTeacher(String usercode) async {
    try {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(),
          );

      await _ref.read(authRepoProvider).teacherRegisterIdCode(usercode);

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              actionOnDone: ActionOnDone.goRegisterData,
            ),
          );
    } on Exception catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'idCodeRegisterTeacher failed',
        information: [
          {'usercode': usercode},
        ],
      );

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
    } finally {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(loading: false),
          );
    }
  }

  Future<void> phoneRegisterTeacher(
    String phone,
  ) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      await _ref.read(authRepoProvider).teacherRegisterPhone(
            phone,
          );

      _ref.read(requestResponseProvider.notifier).update((state) =>
          RequestResponseModel.success(
              actionOnDone: ActionOnDone.goRegisterData));
    } on Exception catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error(exception: e));
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }

  Future<void> loginTeacher(String username, String password) async {
    try {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(),
          );

      final response =
          await _ref.read(authRepoProvider).teacherLogin(username, password);
      _ref.read(tokenStorageProvider).saveToken(response.token!);

      _ref.read(profileProvider);

      state = AuthState.auth;

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              actionOnDone: ActionOnDone.loginSucess,
            ),
          );
    } on Exception catch (e, s) {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'loginTeacher failed',
        information: [
          {'username': username},
        ],
      );
    } finally {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(loading: false),
          );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(),
          );

      final result = await _ref.read(authRepoProvider).forgetPassword(email);

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(message: result.message),
          );
    } on Exception catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'resetPassword failed',
        information: [
          {'email': email},
        ],
      );

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
    } finally {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(loading: false),
          );
    }
  }

  Future<void> logout() async {
    try {
      await _ref.read(authRepoProvider).teacherLogout();

      _ref.read(tokenStorageProvider).deleteToken();

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              actionOnDone: ActionOnDone.unAuth,
            ),
          );
    } on Exception catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'logout failed',
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(),
          );

      await _ref.read(authRepoProvider).deleteMyAccount();

      _ref.read(tokenStorageProvider).deleteToken();

      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              actionOnDone: ActionOnDone.unAuth,
            ),
          );
    } on Exception catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'delete account failed',
      );
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.error(exception: e),
          );
    } finally {
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.loading(loading: false),
          );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

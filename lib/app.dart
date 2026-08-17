import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/utils/token_storage.dart';
import 'package:smart_table_app/features/auth/presentation/views/login_view.dart';
import 'package:smart_table_app/generated/l10n/app_localizations.dart';

import 'core/constants/keys_enums.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/views/splash_view.dart';
import 'core/extensions/context_extensions.dart';
import 'features/profile/providers/locale_notifiers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  /// Tracks whether we've actually shown the loading dialog to avoid race
  /// conditions where the state flips before the dialog is mounted.
  static bool _isLoadingDialogVisible = false;

  void _listenToRequestResponse(WidgetRef ref, BuildContext constext) async {
    ref.listen(
      requestResponseProvider,
      (previous, state) {
        final cuurentContext = ref.watch(navigatorKeyProvider).context;

        // If we came from a dialog-type loading state and the current state
        // is not an active loading, dismiss the dialog. This covers cases
        // where the state transitions directly from loading -> error/success.
        final wasShowingDialog = previous != null &&
            previous.state == RequestResponseState.loading &&
            previous.isLoading &&
            previous.loadingType == LoadingTypes.dialog;

        if ((wasShowingDialog || App._isLoadingDialogVisible) &&
            !(state.state == RequestResponseState.loading && state.isLoading) &&
            cuurentContext != null) {
          Navigator.of(cuurentContext, rootNavigator: true).maybePop();
          App._isLoadingDialogVisible = false;
        }

        if (state.state == RequestResponseState.loading) {
          // Show loading overlay when we start a dialog-type loading
          if (state.isLoading && state.loadingType == LoadingTypes.dialog) {
            if (cuurentContext != null && !App._isLoadingDialogVisible) {
              // Mark as visible immediately and track when it completes so we
              // can avoid race conditions with quick state transitions.
              App._isLoadingDialogVisible = true;
              cuurentContext.showLoadingOverlay().whenComplete(() {
                App._isLoadingDialogVisible = false;
              });
            }

            // When loading finishes, only dismiss the dialog if it was shown
          } else if (!state.isLoading &&
              state.loadingType == LoadingTypes.dialog) {
            // already handled above for both direct transitions and explicit
            // loading=false updates
          }
          // error
        } else if (state.state == RequestResponseState.error) {
          // Handled before the generic message: an expired session has to end
          // at the login screen, otherwise the stale token stays on the device
          // and every later launch resumes a dead session.
          if (state.actionOnDone == ActionOnDone.unAuth) {
            TokenStorage().deleteToken();
            const FlutterSecureStorage().deleteAll();
            cuurentContext?.pushAndRemoveOthers(const LoginView());
            cuurentContext
                ?.showSnackbarError(cuurentContext.locale.sessionExpired);
          } else {
            cuurentContext?.showSnackbarError(exceptionHandler(
                    context: cuurentContext, exception: state.exception) ??
                cuurentContext.locale.errorMessage);
          }

          // sucess
        } else if (state.state == RequestResponseState.success &&
            state.actionOnDone == ActionOnDone.showSucessMessage) {
          cuurentContext?.showSnackbarSuccess(
            state.message ?? cuurentContext.locale.sucessMessage,
          );
        } else if (state.state == RequestResponseState.success &&
            state.actionOnDone == ActionOnDone.showSucessMessageAndPop) {
          cuurentContext?.pop();
          cuurentContext?.showSnackbarSuccess(
            state.message ?? cuurentContext.locale.sucessMessage,
          );
        } else if (state.state == RequestResponseState.success &&
            state.actionOnDone == ActionOnDone.unAuth) {
          const storage = FlutterSecureStorage();
          storage.deleteAll();
          cuurentContext?.pushAndRemoveOthers(const LoginView());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToRequestResponse(ref, context);

    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp(
      navigatorKey: ref.watch(navigatorKeyProvider).navigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (_, child) {
        return _Unfocus(child: child!);
      },
      title: 'Smart Table',
      theme: AppThemes().appTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: currentLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: const SplashView(),
    );
  }
}

/// A widget that unfocus everything when tapped.
///
/// This implements the "Unfocus when tapping in empty space" behavior for the
/// entire application.
class _Unfocus extends StatelessWidget {
  const _Unfocus({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}

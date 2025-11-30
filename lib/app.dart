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
  void _listenToRequestResponse(WidgetRef ref, BuildContext constext) async {
    ref.listen(
      requestResponseProvider,
      (_, state) {
        final cuurentContext = ref.watch(navigatorKeyProvider).context;

        if (state.state == RequestResponseState.loading) {
          if (state.isLoading && state.loadingType == LoadingTypes.dialog) {
            cuurentContext?.showLoadingOverlay();
          } else if (!state.isLoading &&
              state.loadingType == LoadingTypes.dialog) {
            if (cuurentContext != null &&
                Navigator.of(cuurentContext).canPop()) {
              cuurentContext.pop();
            }
          }
          // error
        } else if (state.state == RequestResponseState.error) {
          cuurentContext?.showSnackbarError(exceptionHandler(
                  context: cuurentContext, exception: state.exception) ??
              cuurentContext.locale.errorMessage);
        } else if (state.state == RequestResponseState.error &&
            state.actionOnDone == ActionOnDone.unAuth) {
          const storage = FlutterSecureStorage();
          storage.deleteAll();
          cuurentContext?.pushAndRemoveOthers(const LoginView());

          final isUnAuth = state.actionOnDone == ActionOnDone.unAuth;
          if (isUnAuth) {
            final storage = TokenStorage();
            storage.deleteToken();
            cuurentContext?.pushAndRemoveOthers(const LoginView());
          }
          cuurentContext?.showSnackbarError(isUnAuth
              ? cuurentContext.locale.sessionExpired
              : exceptionHandler(
                      context: cuurentContext, exception: state.exception) ??
                  cuurentContext.locale.errorMessage);
          if (state.actionOnDone == ActionOnDone.unAuth) {
            const storage = FlutterSecureStorage();
            storage.deleteAll();
            cuurentContext?.pushAndRemoveOthers(const LoginView());
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

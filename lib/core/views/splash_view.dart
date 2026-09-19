import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svg_flutter/svg.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/providers/providers.dart';
import 'package:smart_table_app/core/service/app_update_service.dart';
import 'package:smart_table_app/core/service/firebase_messaging_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/utils/token_storage.dart';
import 'package:smart_table_app/core/widgets/app_update_dialog.dart';
import 'package:smart_table_app/features/auth/presentation/views/login_view.dart';
import 'package:smart_table_app/features/layout/views/main_layout_view.dart';
import 'package:smart_table_app/features/profile/providers/profile_provider.dart';

import '../../features/auth/data/repositories/auth_repo.dart';
import '../../features/auth/providers/check_login_provider.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  bool _isHandlingInitialRoute = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(checkLoginProvider, (previous, next) {
      _handleInitialRoute(next);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Top Text "الجدول الذكي" using AppAssets.arFont
              Text(
                context.locale.appTitle,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.arFont,
                ),
              ),
              const SizedBox(height: 16),
              // Main Logo
              Image.asset(
                PngAssets.teacherAppLogo,
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // "Smartble" Text
              const Text(
                'Smartble',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.agencyFont,
                ),
              ),
              const Spacer(flex: 1),
              // "نحو إدارة مدرسية ذكية" with horizontal lines
              Row(
                children: [
                  const Expanded(
                      child:
                          Divider(color: AppColors.primaryColor, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.locale.splashSlogan,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppAssets.arFont,
                      ),
                    ),
                  ),
                  const Expanded(
                      child:
                          Divider(color: AppColors.primaryColor, thickness: 1)),
                ],
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      SvgAssets.shieldCheck,
                      colorFilter: const ColorFilter.mode(
                          AppColors.secondryColor, BlendMode.srcIn),
                      width: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.locale.splashSafeEnv,
                      style: const TextStyle(
                        color: AppColors.secondryColor,
                        fontSize: 14,
                        fontFamily: AppAssets.arFont,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleInitialRoute(AsyncValue<bool> loginState) async {
    if (_isHandlingInitialRoute) return;
    _isHandlingInitialRoute = true;

    final firstRun = await _checkFirstRun();
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    await _showUpdateIfAvailable();
    if (!mounted) return;

    if (loginState.hasValue && !firstRun && loginState.requireValue) {
      try {
        await FirebaseMessagingService().initNotifications(ref);
        final profile = await ref.read(profileProvider.future);
        if (profile.fcmToken == null || profile.fcmToken!.isEmpty) {
          await ref.read(authRepoProvider).updateFcm();
        }
        if (!mounted) return;
        context.pushAndRemoveWithoutTransition(const MainLayoutView());
        return;
      } on AuthenticationException {
        await ref.read(tokenStorageProvider).deleteToken();
      } on Exception {
        // Continue to login when restoring the authenticated session fails.
      }
    }

    if (!mounted) return;
    context.pushAndRemoveWithoutTransition(const LoginView());
  }

  Future<void> _showUpdateIfAvailable() async {
    try {
      final update = await AppUpdateService(
        ref.read(apiServiceProvider),
      ).checkForUpdate();
      if (!mounted || update == null || !update.isUpdateAvailable) return;
      await showAppUpdateDialog(context, update);
    } on Exception {
      // An update check must never prevent the app from starting.
    }
  }

  Future<bool> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    if (isFirstRun) {
      // Clear secure storage
      const storage = FlutterSecureStorage();
      await storage.deleteAll();

      // Set flag to false
      await prefs.setBool('first_run', false);
      return true;
    }
    return false;
  }
}

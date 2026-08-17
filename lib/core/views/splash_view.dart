import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:svg_flutter/svg.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/auth/presentation/views/login_view.dart';
import 'package:smart_table_app/features/layout/views/main_layout_view.dart';

import '../../features/auth/providers/check_login_provider.dart';
import '../providers/providers.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  /// How long the branding stays on screen. Startup work runs in parallel with
  /// it, so this is a floor rather than a delay added on top.
  static const _minimumSplashDuration = Duration(milliseconds: 2000);

  /// Reading the token hits the iOS keychain, which can stall on the first
  /// launch after an update. Nothing here may block forever.
  static const _startupTimeout = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Decides which screen to open. Every path through this method navigates:
  /// a failing startup check must never strand the user on the splash screen.
  Future<void> _bootstrap() async {
    final minimumSplash = Future<void>.delayed(_minimumSplashDuration);
    var isLoggedIn = false;

    try {
      final isFreshInstall = await _clearCredentialsOnFreshInstall();
      if (!isFreshInstall) {
        isLoggedIn =
            await ref.read(checkLoginProvider.future).timeout(_startupTimeout);
      }
    } catch (error, stack) {
      // Best effort: an unreadable token just means "not logged in".
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'splash bootstrap failed',
      );
    }

    await minimumSplash;
    if (!mounted) return;

    context.pushAndRemoveWithoutTransition(
      isLoggedIn ? const MainLayoutView(requestFcm: true) : const LoginView(),
    );
  }

  /// The iOS keychain survives app deletion but SharedPreferences does not, so
  /// a missing `first_run` flag means any stored credentials belong to a
  /// previous install and have to go.
  Future<bool> _clearCredentialsOnFreshInstall() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (!(prefs.getBool('first_run') ?? true)) return false;

    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    await prefs.setBool('first_run', false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
}

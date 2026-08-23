import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svg_flutter/svg.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/service/firebase_messaging_service.dart';
import 'package:smart_table_app/features/auth/presentation/views/login_view.dart';
import 'package:smart_table_app/features/layout/views/main_layout_view.dart';
import 'package:smart_table_app/features/profile/providers/profile_provider.dart';

import '../../features/auth/data/repositories/auth_repo.dart';
import '../../features/auth/providers/check_login_provider.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(checkLoginProvider, (previous, next) async {
      final firstRun = await checkFirstRun();
      if (next.hasValue && !firstRun) {
        //

        //
        if (next.requireValue == true) {
          Future.delayed(const Duration(milliseconds: 2000), () async {
            await FirebaseMessagingService().initNotifications(ref);
            await ref.read(profileProvider.future).then((value) async {
              if (value.fcmToken == null || value.fcmToken!.isEmpty) {
                await ref.read(authRepoProvider).updateFcm();
              }
            });
            context.pushAndRemoveWithoutTransition(const MainLayoutView());
          });
        } else {
          Future.delayed(const Duration(milliseconds: 2000), () {
            context.pushAndRemoveWithoutTransition(const LoginView());
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 2000), () {
          context.pushAndRemoveWithoutTransition(const LoginView());
        });
      }
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

  Future<bool> checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('first_run') ?? true;

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

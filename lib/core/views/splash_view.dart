import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            PngAssets.splashLogo,
          ),
        ],
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

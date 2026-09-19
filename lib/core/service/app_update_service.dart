import 'dart:convert' show jsonDecode, utf8;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/endpoints.dart';
import '../models/app_update_info.dart';
import 'api_service.dart';

class AppUpdateService {
  AppUpdateService(this._apiService);

  final ApiService _apiService;

  static const _appType = 'teacher';
  static const _iosAppId = '1565596183';

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return null;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final platform =
        defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';
    final response = await _apiService.getRaw(
      Endpoints.appVersion,
      parameters: {
        'app': _appType,
        'platform': platform,
        'version': packageInfo.version,
        'build': packageInfo.buildNumber,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final body = utf8.decode(response.bodyBytes);
    if (body.isEmpty) return null;

    final update = AppUpdateInfo.fromResponse(
      jsonDecode(body),
      currentVersion: packageInfo.version,
      currentBuild: packageInfo.buildNumber,
    );

    return update.withFallbackStoreUrl(_fallbackStoreUrl(packageInfo));
  }

  String _fallbackStoreUrl(PackageInfo packageInfo) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://play.google.com/store/apps/details'
          '?id=${packageInfo.packageName}';
    }
    return 'https://apps.apple.com/app/id$_iosAppId';
  }
}

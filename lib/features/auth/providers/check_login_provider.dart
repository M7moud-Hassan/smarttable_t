import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/keys_enums.dart';

final checkLoginProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: SharedPreferenceKeys.token.name);
  return token != null;
});

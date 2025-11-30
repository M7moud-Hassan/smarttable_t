import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final pickedFileProvider = StateProvider.autoDispose<File?>((ref) {
  return null;
});

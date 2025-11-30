import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final navigatorKeyProvider = Provider<NavigatorKeyProvider>((ref) {
  return NavigatorKeyProvider(ref);
});

class NavigatorKeyProvider {
  NavigatorKeyProvider(this.ref);
  final Ref ref;

  final navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentState?.overlay?.context;
}

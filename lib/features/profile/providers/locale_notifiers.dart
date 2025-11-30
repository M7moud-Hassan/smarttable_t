import 'package:flutter/widgets.dart' show Locale;
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show Ref, StateNotifier, StateNotifierProvider, StateProvider;
import 'package:smart_table_app/core/providers/providers.dart';
import 'package:smart_table_app/features/home/providers/home_menu_provider.dart';
import 'package:smart_table_app/features/profile/providers/profile_provider.dart';

import '../../../core/constants/constants.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._ref) : super(null);

  final Ref _ref;
  bool _localeChanged = false; //variable to track locale change

  void changeLocale(Locale locale,
      {final bool sync = false, bool female = true}) async {
    // if (locale == state) return;
    final prefs = _ref.read(sharedPreferencesProvider);

    await prefs.setString(
        SharedPreferenceKeys.locale.name, locale.languageCode);
    if (locale.languageCode == 'ar') {
      await prefs.setBool(SharedPreferenceKeys.localeFemale.name, female);
    }
    await prefs.setString(
        SharedPreferenceKeys.locale.name, locale.languageCode);
    state = locale;
    if (sync) {
      _ref.invalidate(profileProvider);
      _ref.invalidate(homeMenuProvider);
    }
  }

  void defaultToDeviceLocale(Locale? locale) {
    if (locale == null) return;
    _ref.read(selectedLocaleProvider.notifier).state = state;
    changeLocale(locale);
  }

  void getLocale() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final savedLocale = prefs.getString(SharedPreferenceKeys.locale.name);
    state = state ??
        (savedLocale != null ? Locale(savedLocale) : const Locale('ar'));
    _ref.read(selectedLocaleProvider.notifier).state = state;
  }

// Function to check if the locale has changed
  bool hasLocaleChanged() {
    final changed = _localeChanged;
    _localeChanged = false; // Reset the flag after checking

    return changed;
  }
}

final isLocaleArProvider = StateProvider<bool>((ref) {
  return ref.watch(currentLocaleProvider)?.languageCode == 'ar';
});
final currentLocaleProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});
final selectedLocaleProvider = StateProvider<Locale?>((ref) {
  return null;
});

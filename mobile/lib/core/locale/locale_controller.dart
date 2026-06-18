import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs) : super(_initial(_prefs));

  final SharedPreferences _prefs;

  // Орыс тілі бірінші — әдепкі әрі кез келген fallback ru болады.
  static const supported = <Locale>[
    Locale('ru'),
    Locale('kk'),
    Locale('en'),
  ];

  static Locale _initial(SharedPreferences prefs) {
    final code = prefs.getString(_localeKey);
    if (code != null && supported.any((l) => l.languageCode == code)) {
      return Locale(code);
    }
    // Default: Russian. Switch таңдау SharedPreferences-те сақталады.
    return const Locale('ru');
  }

  Future<void> set(Locale locale) async {
    state = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() after async load'),
);

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(ref.watch(sharedPreferencesProvider)),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';

const _subsKey = 'provider_subs_v1';

/// Пайдаланушы подписаться еткен провайдерлердің id-лері (локалды сақталады).
class ProviderSubsController extends StateNotifier<Set<String>> {
  ProviderSubsController(this._prefs)
      : super((_prefs.getStringList(_subsKey) ?? const []).toSet());

  final SharedPreferences _prefs;

  Future<void> _persist() => _prefs.setStringList(_subsKey, state.toList());

  bool isSubscribed(String id) => state.contains(id);

  void toggle(String id) {
    final next = Set<String>.from(state);
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
    _persist();
  }
}

final providerSubsProvider =
    StateNotifierProvider<ProviderSubsController, Set<String>>(
  (ref) => ProviderSubsController(ref.watch(sharedPreferencesProvider)),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';

const _subsKey = 'provider_subs_v1';

/// Пайдаланушы подписаться еткен провайдерлердің id-лері.
/// Remote режимде backend (`/me/subscriptions` + subscribe/unsubscribe);
/// mock режимде локал SharedPreferences.
class ProviderSubsController extends StateNotifier<Set<String>> {
  ProviderSubsController(this._ref)
      : super((_ref.read(sharedPreferencesProvider).getStringList(_subsKey) ?? const []).toSet()) {
    if (AppConfig.useRemoteApi) _loadRemote();
  }

  final Ref _ref;
  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  Future<void> _loadRemote() async {
    try {
      final list = await _ref.read(apiServiceProvider).mySubscriptions();
      state = list.map((e) => (e as Map)['id'].toString()).toSet();
    } catch (_) {
      // желі қатесі — локал кэш қалады
    }
  }

  Future<void> _persist() => _prefs.setStringList(_subsKey, state.toList());

  bool isSubscribed(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final wasSubscribed = state.contains(id);
    final next = Set<String>.from(state);
    wasSubscribed ? next.remove(id) : next.add(id);
    state = next; // оптимистік жаңарту

    if (!AppConfig.useRemoteApi) {
      await _persist();
      return;
    }
    try {
      final api = _ref.read(apiServiceProvider);
      wasSubscribed ? await api.unsubscribe(id) : await api.subscribe(id);
    } catch (_) {
      // қате — кері қайтарамыз
      final revert = Set<String>.from(state);
      wasSubscribed ? revert.add(id) : revert.remove(id);
      state = revert;
    }
  }
}

final providerSubsProvider =
    StateNotifierProvider<ProviderSubsController, Set<String>>(
  (ref) => ProviderSubsController(ref),
);

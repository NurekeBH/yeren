import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';

const _unlockedKey = 'unlocked_signals_v1';

/// Ашылған (сатып алынған) идеялардың id-жинағы.
/// Mock режимде локал (SharedPreferences) тұрады; remote режимде backend-пен
/// синхрондалады (сатып алынғандар сервермен расталады).
class SignalUnlockController extends StateNotifier<Set<String>> {
  SignalUnlockController(this._prefs, this._ref) : super(_load(_prefs)) {
    if (AppConfig.useRemoteApi) _loadRemote();
  }

  final SharedPreferences _prefs;
  final Ref _ref;

  static Set<String> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_unlockedKey);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {}; // бұзық/ескі prefs — краш бермейміз
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_unlockedKey, jsonEncode(state.toList()));
  }

  Future<void> _loadRemote() async {
    try {
      final ids = await _ref.read(apiServiceProvider).purchasedSignals();
      if (ids.isNotEmpty) {
        state = {...state, ...ids};
        await _persist();
      }
    } catch (_) {
      // оффлайн/қате — локал жинақпен жұмыс істей береміз
    }
  }

  bool isUnlocked(String signalId) => state.contains(signalId);

  /// Идеяны ашу (төлемнен кейін шақырылады). Remote режимде backend-ке сатып
  /// алуды тіркейді; mock режимде тек локал тізімге қосады.
  Future<void> unlock(String signalId) async {
    if (state.contains(signalId)) return;
    if (AppConfig.useRemoteApi) {
      await _ref.read(apiServiceProvider).purchaseSignal(signalId);
    }
    state = {...state, signalId};
    await _persist();
  }
}

final signalUnlockProvider =
    StateNotifierProvider<SignalUnlockController, Set<String>>(
  (ref) => SignalUnlockController(ref.watch(sharedPreferencesProvider), ref),
);

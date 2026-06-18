import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';

/// Трейдердің сигналға қосқан follow-up хабары (мыс. «әлі ұстап тұрмын, TP3 күтемін»).
class SignalUpdate {
  const SignalUpdate({required this.text, required this.createdAtIso});
  final String text;
  final String createdAtIso;

  Map<String, dynamic> toJson() => {'t': text, 'c': createdAtIso};
  factory SignalUpdate.fromJson(Map<String, dynamic> j) =>
      SignalUpdate(text: (j['t'] ?? '').toString(), createdAtIso: (j['c'] ?? '').toString());

  /// Backend пішімі (text + created_at).
  factory SignalUpdate.fromApi(Map<String, dynamic> j) => SignalUpdate(
        text: (j['text'] ?? '').toString(),
        createdAtIso: (j['created_at'] ?? '').toString(),
      );
}

const _updatesKey = 'signal_updates_v1';

/// Сигнал бойынша трейдер апдейттері (timeline). Mock — локал; remote — backend.
class SignalUpdatesController extends StateNotifier<Map<String, List<SignalUpdate>>> {
  SignalUpdatesController(this._prefs, this._ref) : super(_load(_prefs));

  final SharedPreferences _prefs;
  final Ref _ref;

  static Map<String, List<SignalUpdate>> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_updatesKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(
          k,
          (v as List).map((e) => SignalUpdate.fromJson((e as Map).cast<String, dynamic>())).toList(),
        ));
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _updatesKey,
      jsonEncode(state.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))),
    );
  }

  List<SignalUpdate> of(String signalId) => state[signalId] ?? const [];

  Future<void> add(String signalId, String text, String nowIso) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final update = SignalUpdate(text: trimmed, createdAtIso: nowIso);
    state = {...state, signalId: [...of(signalId), update]};
    await _persist();
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(apiServiceProvider).addSignalUpdate(signalId, trimmed);
      } catch (_) {/* best-effort */}
    }
  }
}

final signalUpdatesProvider =
    StateNotifierProvider<SignalUpdatesController, Map<String, List<SignalUpdate>>>(
  (ref) => SignalUpdatesController(ref.watch(sharedPreferencesProvider), ref),
);

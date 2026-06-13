import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/signal.dart';

const _mySignalsKey = 'my_signals_v1';

/// Расталған трейдер жариялаған сигналдар (жергілікті, mock). Статусын өзгерте/жаба алады.
/// Remote режимде backend-ке де publish/close шақырады.
class MySignalsController extends StateNotifier<List<Signal>> {
  MySignalsController(this._prefs, this._ref) : super(_load(_prefs));

  final SharedPreferences _prefs;
  final Ref _ref;

  static List<Signal> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_mySignalsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Signal.fromJsonLocal((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> _persist() async {
    await _prefs.setString(_mySignalsKey, jsonEncode(state.map((s) => s.toJson()).toList()));
  }

  /// XAU/USD: нәтижені пипспен есептеу (TP → +, SL → −).
  static int _pipsFor(Signal s, SignalStatus status) {
    final target = switch (status) {
      SignalStatus.closedTp1 => s.tp1,
      SignalStatus.closedTp2 => s.tp2,
      SignalStatus.closedTp3 => s.tp3,
      SignalStatus.closedSl => s.sl,
      SignalStatus.active => s.entryMid,
    };
    final dist = ((target - s.entryMid).abs() / Signal.pipSize).round();
    return status == SignalStatus.closedSl ? -dist : dist;
  }

  Future<void> publish(Signal signal) async {
    state = [signal, ...state];
    await _persist();
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(apiServiceProvider).publishSignal(_toApi(signal));
      } catch (_) {/* best-effort */}
    }
  }

  Future<void> setStatus(String id, SignalStatus status) async {
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(status: status, resultPips: _pipsFor(s, status)) else s,
    ];
    await _persist();
    if (AppConfig.useRemoteApi && status != SignalStatus.active) {
      try {
        final s = state.firstWhere((e) => e.id == id);
        await _ref.read(apiServiceProvider).closeSignal(id, status.name, s.resultPips ?? 0);
      } catch (_) {/* best-effort */}
    }
  }

  Map<String, dynamic> _toApi(Signal s) => {
        'pair': s.pair,
        'direction': s.direction.name,
        'entry_from': s.entryFrom,
        'entry_to': s.entryTo,
        'tp1': s.tp1,
        'tp2': s.tp2,
        'tp3': s.tp3,
        'sl': s.sl,
        'rr': s.rr,
        'confidence': s.confidence,
        'analysis': s.analysis,
        'is_free': s.isFree,
      };
}

final mySignalsProvider = StateNotifierProvider<MySignalsController, List<Signal>>(
  (ref) => MySignalsController(ref.watch(sharedPreferencesProvider), ref),
);

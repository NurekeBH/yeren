import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/price_alert.dart';

const _alertsKey = 'price_alerts_v1';

final _uuidRe = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-');

/// Баға ескертулері. Remote режимде backend (`/alerts`), mock режимде локал.
class PriceAlertController extends StateNotifier<List<PriceAlert>> {
  PriceAlertController(this._ref) : super(_load(_ref.read(sharedPreferencesProvider))) {
    if (AppConfig.useRemoteApi) _loadRemote();
  }

  final Ref _ref;
  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  static List<PriceAlert> _load(SharedPreferences prefs) {
    final list = prefs.getStringList(_alertsKey) ?? const [];
    return list.map(PriceAlert.decode).toList();
  }

  Future<void> _loadRemote() async {
    try {
      final list = await _ref.read(apiServiceProvider).alerts();
      state = list.map((e) => PriceAlert.fromApi((e as Map).cast<String, dynamic>())).toList();
    } catch (_) {
      // желі қатесі — локал кэш қалады
    }
  }

  Future<void> _persist() async {
    await _prefs.setStringList(_alertsKey, state.map((a) => a.encode()).toList());
  }

  Future<void> add(PriceAlert alert) async {
    if (AppConfig.useRemoteApi) {
      try {
        final res = await _ref.read(apiServiceProvider).createAlert({
          'instrument': alert.instrument,
          'target_price': alert.targetPrice,
          'pips': alert.pips,
          'text': alert.text,
          'idea_id': (alert.ideaId != null && _uuidRe.hasMatch(alert.ideaId!)) ? alert.ideaId : null,
        });
        final created = res['alert'] is Map
            ? PriceAlert.fromApi((res['alert'] as Map).cast<String, dynamic>())
            : alert;
        state = [created, ...state];
      } catch (_) {
        // желі қатесі — қосылмайды
      }
      return;
    }
    state = [alert, ...state];
    await _persist();
  }

  Future<void> remove(String id) async {
    final prev = state;
    state = state.where((a) => a.id != id).toList();
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(apiServiceProvider).deleteAlert(id);
      } catch (_) {
        state = prev; // қате — қайтарамыз
      }
      return;
    }
    await _persist();
  }
}

final priceAlertControllerProvider =
    StateNotifierProvider<PriceAlertController, List<PriceAlert>>(
  (ref) => PriceAlertController(ref),
);

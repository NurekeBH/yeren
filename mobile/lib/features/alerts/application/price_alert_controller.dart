import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/price_alert.dart';

const _alertsKey = 'price_alerts_v1';

/// Баға ескертулерін локалды сақтайтын контроллер (SharedPreferences).
class PriceAlertController extends StateNotifier<List<PriceAlert>> {
  PriceAlertController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static List<PriceAlert> _load(SharedPreferences prefs) {
    final list = prefs.getStringList(_alertsKey) ?? const [];
    return list.map(PriceAlert.decode).toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(_alertsKey, state.map((a) => a.encode()).toList());
  }

  void add(PriceAlert alert) {
    state = [alert, ...state];
    _persist();
  }

  void remove(String id) {
    state = state.where((a) => a.id != id).toList();
    _persist();
  }
}

final priceAlertControllerProvider =
    StateNotifierProvider<PriceAlertController, List<PriceAlert>>(
  (ref) => PriceAlertController(ref.watch(sharedPreferencesProvider)),
);

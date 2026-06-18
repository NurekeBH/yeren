import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart' show sharedPreferencesProvider;

/// Промокодпен тіркелулердің құрылғы-жергілікті есебі (код → саны).
///
/// Remote режимде нақты санды backend береді (referral_count). Mock режимде
/// бұл тізілім сол құрылғыда қолданылған промокодтарды санайды — сондықтан
/// трейдер өз кодымен «қанша адам тіркелгенін» демо-режимде де көре алады.
class PromoRegistry extends StateNotifier<Map<String, int>> {
  PromoRegistry(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'promo_registry_v1';

  static Map<String, int> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return map.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  /// Код бойынша тіркелуді +1 (промокод сәтті қолданылғанда).
  void record(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return;
    final next = Map<String, int>.from(state);
    next[c] = (next[c] ?? 0) + 1;
    state = next;
    _prefs.setString(_key, jsonEncode(next));
  }

  int countFor(String code) => state[code.trim().toUpperCase()] ?? 0;
}

final promoRegistryProvider =
    StateNotifierProvider<PromoRegistry, Map<String, int>>(
  (ref) => PromoRegistry(ref.watch(sharedPreferencesProvider)),
);

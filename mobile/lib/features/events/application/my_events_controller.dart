import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/trading_event.dart';

const _myEventsKey = 'my_events_v1';

/// Расталған трейдер жариялаған іс-шаралар (жергілікті, mock).
/// Remote режимде backend-ке де publish шақырады.
class MyEventsController extends StateNotifier<List<TradingEvent>> {
  MyEventsController(this._prefs, this._ref) : super(_load(_prefs));

  final SharedPreferences _prefs;
  final Ref _ref;

  static List<TradingEvent> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_myEventsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => TradingEvent.fromJsonLocal((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> _persist() async {
    await _prefs.setString(_myEventsKey, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> publish(TradingEvent event) async {
    state = [event, ...state];
    await _persist();
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(apiServiceProvider).publishEvent(_toApi(event));
      } catch (_) {/* best-effort */}
    }
  }

  Map<String, dynamic> _toApi(TradingEvent e) => {
        'type': e.type.name,
        'title': e.title,
        'speaker': e.speaker,
        'city': e.city,
        'date': e.dateIso,
        'price': e.price,
        'is_online': e.isOnline,
        'description': e.description,
        if (e.youtubeId != null) 'youtube_id': e.youtubeId,
      };
}

final myEventsProvider = StateNotifierProvider<MyEventsController, List<TradingEvent>>(
  (ref) => MyEventsController(ref.watch(sharedPreferencesProvider), ref),
);

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';

/// Бір библиотека элементі бойынша пайдаланушы деректері: сақталған ба, бағасы, отзыв.
class LibraryUserEntry {
  const LibraryUserEntry({this.saved = false, this.rating = 0, this.review = ''});

  final bool saved;
  final int rating; // 0 = баға жоқ
  final String review;

  LibraryUserEntry copyWith({bool? saved, int? rating, String? review}) => LibraryUserEntry(
        saved: saved ?? this.saved,
        rating: rating ?? this.rating,
        review: review ?? this.review,
      );

  Map<String, dynamic> toJson() => {'s': saved, 'r': rating, 'rv': review};
  factory LibraryUserEntry.fromJson(Map<String, dynamic> j) => LibraryUserEntry(
        saved: j['s'] as bool? ?? false,
        rating: j['r'] as int? ?? 0,
        review: j['rv'] as String? ?? '',
      );
}

const _libUserKey = 'library_user_data_v1';

/// Remote режимде backend (`/library/me` + PUT `/library/:itemId`),
/// mock режимде локал SharedPreferences.
class LibrarySavedController extends StateNotifier<Map<String, LibraryUserEntry>> {
  LibrarySavedController(this._ref) : super(_load(_ref.read(sharedPreferencesProvider))) {
    if (AppConfig.useRemoteApi) _loadRemote();
  }

  final Ref _ref;
  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  static Map<String, LibraryUserEntry> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_libUserKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, LibraryUserEntry.fromJson(v as Map<String, dynamic>)));
    } catch (_) {
      return {};
    }
  }

  Future<void> _loadRemote() async {
    try {
      final items = await _ref.read(apiServiceProvider).myLibrary();
      final map = <String, LibraryUserEntry>{};
      for (final raw in items) {
        final j = (raw as Map).cast<String, dynamic>();
        map[j['item_id'].toString()] = LibraryUserEntry(
          saved: j['saved'] == true,
          rating: j['rating'] is num ? (j['rating'] as num).toInt() : int.tryParse('${j['rating']}') ?? 0,
          review: (j['review'] ?? '').toString(),
        );
      }
      state = map;
    } catch (_) {
      // желі қатесі — локал кэш қалады
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_libUserKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))));
  }

  LibraryUserEntry entry(String id) => state[id] ?? const LibraryUserEntry();

  void _update(String id, LibraryUserEntry e, Map<String, dynamic> patch) {
    state = {...state, id: e};
    if (AppConfig.useRemoteApi) {
      _ref.read(apiServiceProvider).upsertLibrary(id, patch).catchError((_) {});
    } else {
      _persist();
    }
  }

  void toggleSaved(String id) {
    final e = entry(id).copyWith(saved: !entry(id).saved);
    _update(id, e, {'saved': e.saved});
  }

  void setRating(String id, int rating) {
    final e = entry(id).copyWith(rating: rating);
    _update(id, e, {'rating': rating});
  }

  void setReview(String id, String review) {
    final e = entry(id).copyWith(review: review);
    _update(id, e, {'review': review});
  }

  List<String> get savedIds =>
      state.entries.where((e) => e.value.saved).map((e) => e.key).toList();
}

final librarySavedProvider =
    StateNotifierProvider<LibrarySavedController, Map<String, LibraryUserEntry>>(
  (ref) => LibrarySavedController(ref),
);

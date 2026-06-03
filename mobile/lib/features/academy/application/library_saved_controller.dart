import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';

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

class LibrarySavedController extends StateNotifier<Map<String, LibraryUserEntry>> {
  LibrarySavedController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Map<String, LibraryUserEntry> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_libUserKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, LibraryUserEntry.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _persist() async {
    await _prefs.setString(_libUserKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))));
  }

  LibraryUserEntry entry(String id) => state[id] ?? const LibraryUserEntry();

  void _update(String id, LibraryUserEntry e) {
    state = {...state, id: e};
    _persist();
  }

  void toggleSaved(String id) => _update(id, entry(id).copyWith(saved: !entry(id).saved));
  void setRating(String id, int rating) => _update(id, entry(id).copyWith(rating: rating));
  void setReview(String id, String review) => _update(id, entry(id).copyWith(review: review));

  List<String> get savedIds =>
      state.entries.where((e) => e.value.saved).map((e) => e.key).toList();
}

final librarySavedProvider =
    StateNotifierProvider<LibrarySavedController, Map<String, LibraryUserEntry>>(
  (ref) => LibrarySavedController(ref.watch(sharedPreferencesProvider)),
);

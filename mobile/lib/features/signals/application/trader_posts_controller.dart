import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/trader_posts_fixtures.dart';
import '../../../shared/models/trader_post.dart';

/// Бір пост бойынша пайдаланушы әрекеті: лайк басылды ма + қосқан комментарийлер.
class PostUserData {
  const PostUserData({this.liked = false, this.comments = const []});

  final bool liked;
  final List<String> comments;

  PostUserData copyWith({bool? liked, List<String>? comments}) =>
      PostUserData(liked: liked ?? this.liked, comments: comments ?? this.comments);

  Map<String, dynamic> toJson() => {'l': liked, 'c': comments};
  factory PostUserData.fromJson(Map<String, dynamic> j) => PostUserData(
        liked: j['l'] as bool? ?? false,
        comments: (j['c'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

const _postsUserKey = 'trader_posts_user_v1';

class TraderPostsController extends StateNotifier<Map<String, PostUserData>> {
  TraderPostsController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Map<String, PostUserData> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_postsUserKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, PostUserData.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _persist() async {
    await _prefs.setString(_postsUserKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))));
  }

  PostUserData of(String postId) => state[postId] ?? const PostUserData();

  void toggleLike(String postId) {
    final cur = of(postId);
    state = {...state, postId: cur.copyWith(liked: !cur.liked)};
    _persist();
  }

  void addComment(String postId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final cur = of(postId);
    state = {...state, postId: cur.copyWith(comments: [...cur.comments, trimmed])};
    _persist();
  }
}

final traderPostsUserProvider =
    StateNotifierProvider<TraderPostsController, Map<String, PostUserData>>(
  (ref) => TraderPostsController(ref.watch(sharedPreferencesProvider)),
);

/// Берілген провайдердің посттары (локаль бойынша).
final traderPostsProvider = Provider.family<List<TraderPost>, String>((ref, providerId) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return TraderPostsFixtures.forProvider(providerId, loc);
});

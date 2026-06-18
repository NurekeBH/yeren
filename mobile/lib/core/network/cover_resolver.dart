import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/library_item.dart';

// Open Library search баяу әрі көп сұрау қатар жүреді — timeout-ты үлкен қоямыз.
final _coverDio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 20),
  receiveTimeout: const Duration(seconds: 20),
));

Map<String, dynamic>? _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String && data.isNotEmpty) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {}
  }
  return null;
}

/// Кітап мұқабасы — Open Library (кілтсіз, квотасыз). search → cover_i → covers CDN.
Future<String?> _bookCover(LibraryItem item) async {
  try {
    final res = await _coverDio.get<dynamic>(
      'https://openlibrary.org/search.json',
      queryParameters: {
        'title': item.title,
        if (item.author.isNotEmpty) 'author': item.author,
        'limit': 1,
        'fields': 'cover_i,cover_edition_key',
      },
    );
    final data = _asMap(res.data);
    final docs = data?['docs'] as List?;
    if (docs != null && docs.isNotEmpty) {
      final doc = (docs.first as Map);
      final coverId = doc['cover_i'];
      if (coverId != null) {
        return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
      }
      final olid = doc['cover_edition_key']?.toString();
      if (olid != null) {
        return 'https://covers.openlibrary.org/b/olid/$olid-M.jpg';
      }
    }
  } catch (_) {/* желі/квота — fallback */}
  return null;
}

/// Фильм постері — iTunes Search (кілтсіз). artworkUrl100 → 600x600.
Future<String?> _filmCover(LibraryItem item) async {
  try {
    final res = await _coverDio.get<dynamic>(
      'https://itunes.apple.com/search',
      queryParameters: {'term': item.title, 'media': 'movie', 'limit': 1, 'country': 'US'},
    );
    final data = _asMap(res.data);
    final results = data?['results'] as List?;
    if (results != null && results.isNotEmpty) {
      final art = (results.first as Map)['artworkUrl100']?.toString();
      return art?.replaceFirst('100x100bb', '600x600bb');
    }
  } catch (_) {/* желі — fallback */}
  return null;
}

/// Кітап/фильм мұқабасын кілтсіз ашық дереккөзден табады (Open Library / iTunes).
/// Подкаст/explicit URL → бар күйінде. Нәтиже Riverpod-та сессия бойы кэштеледі.
/// Табылмаса/желі болмаса null → виджет стильді градиент мұқабаны көрсетеді.
final coverResolverProvider = FutureProvider.family<String?, LibraryItem>((ref, item) async {
  final explicit = item.coverImageUrl;
  if (explicit != null) return explicit;
  if (item.category == LibraryCategory.book) return _bookCover(item);
  if (item.category == LibraryCategory.film) return _filmCover(item);
  return null;
});

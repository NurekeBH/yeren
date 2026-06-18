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

/// Фильм/сериал постері — Wikipedia (кілтсіз): search → article → summary thumbnail.
Future<String?> _filmCover(LibraryItem item) async {
  const ua = {'User-Agent': 'ALTYN/1.0 (library covers)'};
  try {
    final yr = item.year != null ? ' ${item.year}' : '';
    final search = await _coverDio.get<dynamic>(
      'https://en.wikipedia.org/w/api.php',
      queryParameters: {'action': 'query', 'list': 'search', 'srsearch': '${item.title}$yr', 'format': 'json', 'srlimit': 1},
      options: Options(headers: ua),
    );
    final sd = _asMap(search.data);
    final hits = (sd?['query'] as Map?)?['search'] as List?;
    if (hits == null || hits.isEmpty) return null;
    final page = (hits.first as Map)['title'].toString().replaceAll(' ', '_');
    final sum = await _coverDio.get<dynamic>(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(page)}',
      options: Options(headers: ua),
    );
    final rd = _asMap(sum.data);
    return (rd?['thumbnail'] as Map?)?['source']?.toString();
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

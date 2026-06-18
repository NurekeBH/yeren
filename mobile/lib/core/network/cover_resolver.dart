import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/library_item.dart';

final _coverDio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 6),
  receiveTimeout: const Duration(seconds: 6),
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

/// Кітап/фильм мұқабасын кілтсіз ашық API-дан табады:
/// кітап → Google Books, фильм → iTunes Search. Подкаст/explicit URL → бар күйінде.
/// Нәтиже Riverpod-та сессия бойы кэштеледі (әр элемент бір рет сұралады).
/// Табылмаса null → виджет стильді градиент мұқабаны көрсетеді.
final coverResolverProvider = FutureProvider.family<String?, LibraryItem>((ref, item) async {
  final explicit = item.coverImageUrl;
  if (explicit != null) return explicit;

  try {
    if (item.category == LibraryCategory.book) {
      final res = await _coverDio.get<dynamic>(
        'https://www.googleapis.com/books/v1/volumes',
        queryParameters: {'q': '${item.title} ${item.author}', 'maxResults': 1, 'country': 'US'},
      );
      final data = _asMap(res.data);
      final items = data?['items'] as List?;
      if (items != null && items.isNotEmpty) {
        final vol = (items.first as Map)['volumeInfo'] as Map?;
        final links = vol?['imageLinks'] as Map?;
        final url = (links?['thumbnail'] ?? links?['smallThumbnail'])?.toString();
        return url?.replaceFirst('http://', 'https://');
      }
    } else if (item.category == LibraryCategory.film) {
      final res = await _coverDio.get<dynamic>(
        'https://itunes.apple.com/search',
        queryParameters: {'term': item.title, 'media': 'movie', 'limit': 1},
      );
      final data = _asMap(res.data);
      final results = data?['results'] as List?;
      if (results != null && results.isNotEmpty) {
        final art = (results.first as Map)['artworkUrl100']?.toString();
        // Жоғары ажыратымдылыққа көтереміз (100x100 → 600x600).
        return art?.replaceFirst('100x100bb', '600x600bb');
      }
    }
  } catch (_) {
    // Желі/қате — null қайтарамыз, виджет fallback көрсетеді.
  }
  return null;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/library_item.dart';

// ─── Backend JSON → Lesson / GallupQuestion (енумдар .name арқылы) ───
GallupProfile _profileFromName(String s) =>
    GallupProfile.values.firstWhere((p) => p.name == s, orElse: () => GallupProfile.disciplined);
LessonSourceType _sourceFromName(String s) =>
    LessonSourceType.values.firstWhere((t) => t.name == s, orElse: () => LessonSourceType.book);
LessonTag _tagFromName(String s) =>
    LessonTag.values.firstWhere((t) => t.name == s, orElse: () => LessonTag.psychology);

Lesson lessonFromApi(Map<String, dynamic> j, String loc) {
  final qc = (j['quick_check'] as Map?)?.cast<String, dynamic>() ?? const {};
  return Lesson(
    id: j['id'].toString(),
    profile: _profileFromName((j['profile_type'] ?? '').toString()),
    sourceType: _sourceFromName((j['source_type'] ?? 'book').toString()),
    sourceName: (j['source_name'] ?? '').toString(),
    title: _libPick(j['title'], loc),
    quote: _libPick(j['quote'], loc),
    explanation: _libPick(j['explanation'], loc),
    goldApplication: _libPick(j['gold_application'], loc),
    quickCheck: QuickCheck(
      question: _libPick(qc['question'], loc),
      options: _libPickList(qc['options'], loc),
      correctIndex: (qc['correctIndex'] as num?)?.toInt() ?? 0,
    ),
    xp: (j['xp'] as num?)?.toInt() ?? 25,
    tag: _tagFromName((j['tag'] ?? 'psychology').toString()),
    externalUrl: j['external_url'] as String?,
  );
}

GallupQuestion gallupFromApi(Map<String, dynamic> j, String loc) {
  final opts = (j['options'] as List? ?? const [])
      .map((e) => (e as Map).cast<String, dynamic>())
      .map((o) {
    final scores = (o['scores'] as Map?)?.cast<String, dynamic>() ?? const {};
    return GallupOption(
      label: _libPick(o['label'], loc),
      scores: {for (final e in scores.entries) _profileFromName(e.key): (e.value as num).toInt()},
    );
  }).toList();
  return GallupQuestion(id: j['id'].toString(), text: _libPick(j['text'], loc), options: opts);
}

class LessonsRepository {
  LessonsRepository(this._api);
  final ApiService _api;

  Future<List<Lesson>> fetchAll(String loc) async {
    final raw = await _api.academyLessons();
    return raw.map((e) => lessonFromApi((e as Map).cast<String, dynamic>(), loc)).toList();
  }

  Future<List<Lesson>> fetchForProfile(String loc, GallupProfile profile) async {
    final raw = await _api.academyLessons(profile.name);
    return raw.map((e) => lessonFromApi((e as Map).cast<String, dynamic>(), loc)).toList();
  }

  Future<List<GallupQuestion>> gallupQuestions(String loc) async {
    final raw = await _api.gallupQuestions();
    return raw.map((e) => gallupFromApi((e as Map).cast<String, dynamic>(), loc)).toList();
  }
}

final lessonsRepositoryProvider =
    Provider<LessonsRepository>((ref) => LessonsRepository(ref.watch(apiServiceProvider)));

final allLessonsProvider = FutureProvider<List<Lesson>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(lessonsRepositoryProvider).fetchAll(loc);
});
final gallupQuestionsProvider = FutureProvider<List<GallupQuestion>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(lessonsRepositoryProvider).gallupQuestions(loc);
});

// ─── Backend JSON → LibraryItem (локализацияланатын мәтін {ru,kk,en} картасынан) ───
double? _libD(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
int? _libI(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
String _libPick(dynamic m, String loc) =>
    m is Map ? (m[loc] ?? m['ru'] ?? '').toString() : '';
List<String> _libPickList(dynamic m, String loc) {
  if (m is! Map) return const [];
  final v = m[loc] ?? m['ru'];
  return v is List ? v.map((e) => e.toString()).toList() : const [];
}

LibraryItem libraryItemFromApi(Map<String, dynamic> j, String loc) {
  final catStr = (j['category'] ?? 'book').toString();
  return LibraryItem(
    id: j['id'].toString(),
    category: LibraryCategory.values.firstWhere((c) => c.name == catStr, orElse: () => LibraryCategory.book),
    title: (j['title'] ?? '').toString(),
    author: (j['author'] ?? '').toString(),
    summary: _libPick(j['summary'], loc),
    ideas: _libPickList(j['ideas'], loc),
    conclusion: j['conclusion'] == null ? null : _libPick(j['conclusion'], loc),
    topic: j['topic'] as String?,
    year: _libI(j['year']),
    rating: _libD(j['rating']),
    ratingMax: _libD(j['rating_max']) ?? 5,
    ratingSource: j['rating_source'] as String?,
    isbn: j['isbn'] as String?,
    coverUrl: j['cover_url'] as String?,
    youtubeId: j['youtube_id'] as String?,
    externalUrl: j['external_url'] as String?,
    lang: j['lang'] as String?,
  );
}

/// Библиотека каталогы (Кітап/Фильм/Подкаст) — DB-ден API арқылы, тілге байланысты.
final libraryCatalogProvider = FutureProvider<List<LibraryItem>>((ref) async {
  final loc = ref.watch(localeControllerProvider).languageCode;
  final raw = await ref.watch(apiServiceProvider).libraryCatalog();
  return raw.map((e) => libraryItemFromApi((e as Map).cast<String, dynamic>(), loc)).toList();
});

/// Категория бойынша бөлінген каталог (UI әр build сайын `.where()` жүргізбес үшін).
final libraryByCategoryProvider =
    FutureProvider<Map<LibraryCategory, List<LibraryItem>>>((ref) async {
  final items = await ref.watch(libraryCatalogProvider.future);
  final map = <LibraryCategory, List<LibraryItem>>{
    for (final c in LibraryCategory.values) c: <LibraryItem>[],
  };
  for (final it in items) {
    (map[it.category] ??= <LibraryItem>[]).add(it);
  }
  return map;
});

const _completedKey = 'completed_lessons_v1';

class CompletedLessonsController extends StateNotifier<Set<String>> {
  CompletedLessonsController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Set<String> _load(SharedPreferences prefs) {
    final list = prefs.getStringList(_completedKey);
    return list == null ? <String>{} : list.toSet();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(_completedKey, state.toList());
  }

  void markCompleted(String lessonId) {
    state = {...state, lessonId};
    _persist();
  }

  void reset() {
    _prefs.remove(_completedKey);
    state = <String>{};
  }
}

final completedLessonsProvider =
    StateNotifierProvider<CompletedLessonsController, Set<String>>(
  (ref) => CompletedLessonsController(ref.watch(sharedPreferencesProvider)),
);

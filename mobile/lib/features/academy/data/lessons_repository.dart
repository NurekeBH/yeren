import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../core/mock/library_fixtures.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/library_item.dart';

class LessonsRepository {
  Future<List<Lesson>> fetchAll(String loc) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MockFixtures.lessons(loc);
  }

  Future<List<Lesson>> fetchForProfile(String loc, GallupProfile profile) async {
    final all = await fetchAll(loc);
    return all.where((l) => l.profile == profile).toList();
  }

  Future<List<GallupQuestion>> gallupQuestions(String loc) async => MockFixtures.gallupQuestions(loc);
}

final lessonsRepositoryProvider = Provider<LessonsRepository>((ref) => LessonsRepository());

final allLessonsProvider = FutureProvider<List<Lesson>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(lessonsRepositoryProvider).fetchAll(loc);
});
final gallupQuestionsProvider = FutureProvider<List<GallupQuestion>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(lessonsRepositoryProvider).gallupQuestions(loc);
});

/// Библиотека каталогы (кітаптар/фильмдер/YouTube-подкасттар) — тілге байланысты.
final libraryItemsProvider = Provider<List<LibraryItem>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return LibraryFixtures.all(loc);
});

/// Категория бойынша алдын ала бөлінген каталог (тіл ауысқанда ғана қайта есептеледі).
/// Экран әр build сайын `.where()` жүргізбес үшін кэштеледі — жүктеу/скролл жылдамдау.
final libraryByCategoryProvider =
    Provider<Map<LibraryCategory, List<LibraryItem>>>((ref) {
  final items = ref.watch(libraryItemsProvider);
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

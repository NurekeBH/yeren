import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/course.dart';
import '../../../shared/models/course_json.dart';
import 'video_course.dart';

/// Curriculum премиум-курстар (КОД РЫНКА сияқты, модуль/сабақ/блок ағашы) —
/// DB-ден API арқылы. Видео-курстар бөлек (videoCoursesProvider) — мұнда сүзіледі.
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final loc = ref.watch(localeControllerProvider).languageCode;
  final rows = await ref.watch(courseCatalogRawProvider.future);
  return rows
      .where((j) => (j['content'] as Map?)?['kind'] != 'video')
      .map((j) => _courseFromCatalog(j, loc))
      .toList();
});

int? _ci(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
String _pick(dynamic m, String loc, String fb) =>
    m is Map ? (m[loc] ?? m['ru'] ?? fb).toString() : fb;

/// Каталог жазбасынан Course құру: ағаш content-тен, метадата бағандар басым.
Course _courseFromCatalog(Map<String, dynamic> j, String loc) {
  final tree = courseFromJson((j['content'] as Map?)?.cast<String, dynamic>() ?? const {});
  return Course(
    id: tree.id.isEmpty ? (j['id'] ?? '').toString() : tree.id,
    title: _pick(j['title'], loc, tree.title),
    subtitle: _pick(j['subtitle'], loc, tree.subtitle),
    description: _pick(j['description'], loc, tree.description),
    priceBonus: _ci(j['price_bonus']) ?? tree.priceBonus,
    emoji: (j['emoji'] ?? tree.emoji).toString(),
    accent: _ci(j['accent']) ?? tree.accent,
    modules: tree.modules,
  );
}

/// Курсты id бойынша табу (детал/сабақ экрандарына).
final courseByIdProvider = FutureProvider.family<Course?, String>((ref, id) async {
  final courses = await ref.watch(coursesProvider.future);
  for (final c in courses) {
    if (c.id == id) return c;
  }
  return null;
});

// ── Сатып алынған (ашылған) курстар ───────────────────────────────────
const _purchasedKey = 'purchased_courses_v1';

class PurchasedCoursesController extends StateNotifier<Set<String>> {
  PurchasedCoursesController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Set<String> _load(SharedPreferences prefs) =>
      prefs.getStringList(_purchasedKey)?.toSet() ?? <String>{};

  bool isUnlocked(String courseId) => state.contains(courseId);

  void unlock(String courseId) {
    if (state.contains(courseId)) return;
    state = {...state, courseId};
    _prefs.setStringList(_purchasedKey, state.toList());
  }
}

final purchasedCoursesProvider =
    StateNotifierProvider<PurchasedCoursesController, Set<String>>(
  (ref) => PurchasedCoursesController(ref.watch(sharedPreferencesProvider)),
);

// ── Аяқталған сабақтар (курс прогресі) ────────────────────────────────
const _courseProgressKey = 'course_completed_lessons_v1';

class CourseProgressController extends StateNotifier<Set<String>> {
  CourseProgressController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Set<String> _load(SharedPreferences prefs) =>
      prefs.getStringList(_courseProgressKey)?.toSet() ?? <String>{};

  bool isDone(String lessonId) => state.contains(lessonId);

  void markDone(String lessonId) {
    if (state.contains(lessonId)) return;
    state = {...state, lessonId};
    _prefs.setStringList(_courseProgressKey, state.toList());
  }
}

final courseProgressProvider =
    StateNotifierProvider<CourseProgressController, Set<String>>(
  (ref) => CourseProgressController(ref.watch(sharedPreferencesProvider)),
);

/// Курс бойынша аяқталған сабақтар саны (прогресс жолағы үшін).
/// Курстар async тартылатындықтан, жүктелмеген кезде 0 қайтарады.
final courseDoneCountProvider = Provider.family<int, String>((ref, courseId) {
  final courses = ref.watch(coursesProvider).valueOrNull ?? const <Course>[];
  Course? course;
  for (final c in courses) {
    if (c.id == courseId) {
      course = c;
      break;
    }
  }
  if (course == null) return 0;
  final done = ref.watch(courseProgressProvider);
  return course.allLessons.where((l) => done.contains(l.id)).length;
});

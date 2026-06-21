import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/course.dart';
import 'courses_data.dart';

/// Барлық премиум-курстар каталогы (қазір мазмұн орыс тілінде — кеңейтуге дайын).
final coursesProvider = Provider<List<Course>>((ref) => buildCourses());

/// Курсты id бойынша табу (детал/сабақ экрандарына).
final courseByIdProvider = Provider.family<Course?, String>((ref, id) {
  final courses = ref.watch(coursesProvider);
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
final courseDoneCountProvider = Provider.family<int, String>((ref, courseId) {
  final course = ref.watch(courseByIdProvider(courseId));
  if (course == null) return 0;
  final done = ref.watch(courseProgressProvider);
  return course.allLessons.where((l) => done.contains(l.id)).length;
});

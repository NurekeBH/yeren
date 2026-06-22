import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/course.dart';
import 'course_meta.dart';
import 'courses_data.dart';

/// Барлық премиум-курстар каталогы. Мазмұн courses_data-да, ал «сатылатын»
/// маркетинг қабаты (ілмекті тақырып, эмодзи, минут) + тіл локализациясы
/// course_meta-да — осы жерде біріктіреміз. Тіл ауысса қайта құрылады.
/// ЕСКЕРТУ: сабақ ДЕНЕСІ (blocks) әзірге тек RU (келесі кезеңде аударылады).
final coursesProvider = Provider<List<Course>>((ref) {
  final locale = ref.watch(localeControllerProvider).languageCode;
  return buildCourses().map((c) => _applyMeta(c, locale)).toList();
});

/// Курсқа маркетинг метасын + таңдалған тіл қабығын қолданады.
Course _applyMeta(Course c, String locale) {
  final lessonText = locale == 'kk'
      ? lessonTextKk
      : locale == 'en'
          ? lessonTextEn
          : const <String, LessonText>{};
  final moduleText = locale == 'kk'
      ? moduleTextKk
      : locale == 'en'
          ? moduleTextEn
          : const <String, ModuleText>{};
  final shell = locale == 'kk'
      ? courseShellKk
      : locale == 'en'
          ? courseShellEn
          : null;

  return Course(
    id: c.id,
    title: shell?.title ?? c.title,
    subtitle: shell?.subtitle ?? c.subtitle,
    description: shell?.description ?? c.description,
    priceBonus: c.priceBonus,
    accent: c.accent,
    emoji: c.emoji,
    modules: [
      for (final m in c.modules)
        CourseModule(
          id: m.id,
          index: m.index,
          title: moduleText[m.id]?.title ?? m.title,
          goal: moduleText[m.id]?.goal ?? m.goal,
          emoji: moduleEmoji[m.id] ?? m.emoji,
          lessons: [
            for (final l in m.lessons)
              CourseLesson(
                id: l.id,
                code: l.code,
                title: lessonText[l.id]?.title ?? lessonMeta[l.id]?.title ?? l.title,
                emoji: lessonMeta[l.id]?.emoji ?? l.emoji,
                hook: lessonText[l.id]?.hook ?? lessonMeta[l.id]?.hook ?? l.hook,
                minutes: lessonMeta[l.id]?.minutes ?? l.minutes,
                // Тақырып бойынша фильм/кітап ұсынысы болса — сабақ соңына қосамыз.
                blocks: lessonMedia[l.id] == null
                    ? l.blocks
                    : [
                        ...l.blocks,
                        MediaRecBlock(
                          kind: lessonMedia[l.id]!.kind,
                          title: lessonMedia[l.id]!.title,
                          note: lessonMedia[l.id]!.note,
                          meta: lessonMedia[l.id]!.meta,
                        ),
                      ],
                quiz: l.quiz,
              ),
          ],
        ),
    ],
  );
}

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

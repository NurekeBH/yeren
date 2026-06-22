import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/course.dart';
import '../../../core/network/api_service.dart';
import '../data/courses_repository.dart';
import 'course_unlock_sheet.dart';
import 'widgets/course_interactives.dart';

/// Курс сабағы — свайп-плеер: hero + слайдтар (бір блок = бір слайд) +
/// нүкте-индикатор + соңында тест. UX «finance-kid» стиліне ұқсас.
class CourseLessonScreen extends ConsumerStatefulWidget {
  const CourseLessonScreen({super.key, required this.courseId, required this.lessonId});
  final String courseId;
  final String lessonId;

  @override
  ConsumerState<CourseLessonScreen> createState() => _CourseLessonScreenState();
}

class _CourseLessonScreenState extends ConsumerState<CourseLessonScreen> {
  final _pc = PageController();
  int _page = 0;

  // Тест күйі.
  int? _selected;
  bool _submitted = false;

  // Слайдтарды кэштейміз — әр свайп сайын (setState) қайта топтамас үшін.
  List<List<LessonBlock>>? _slidesCache;
  String? _slidesForLesson;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  /// Кэштелген слайдтар (сабақ ауысса ғана қайта есептеледі).
  List<List<LessonBlock>> _slidesFor(CourseLesson lesson) {
    if (_slidesForLesson == lesson.id && _slidesCache != null) return _slidesCache!;
    _slidesCache = _groupSlides(lesson.blocks);
    _slidesForLesson = lesson.id;
    return _slidesCache!;
  }

  /// Блоктарды слайдтарға топтайды: қатарынан келген мәтін (Heading/Paragraph)
  /// бір слайдқа, ал callout/formula/interactive/cards — әрқайсысы жеке слайдқа.
  List<List<LessonBlock>> _groupSlides(List<LessonBlock> blocks) {
    final slides = <List<LessonBlock>>[];
    var run = <LessonBlock>[];
    void flush() {
      if (run.isNotEmpty) {
        slides.add(run);
        run = <LessonBlock>[];
      }
    }

    for (final b in blocks) {
      if (b is ParagraphBlock || b is HeadingBlock) {
        run.add(b);
      } else {
        flush();
        slides.add([b]);
      }
    }
    flush();
    return slides;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final course = ref.watch(courseByIdProvider(widget.courseId));
    if (course == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final lessons = course.allLessons;
    final idx = lessons.indexWhere((x) => x.id == widget.lessonId);
    if (idx < 0) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final lesson = lessons[idx];
    final accent = Color(course.accent);
    final next = idx + 1 < lessons.length ? lessons[idx + 1] : null;

    // Контентті қорғау: курсты сатып алмаған пайдаланушы сабақ мазмұнын көрмейді
    // (deep link арқылы кірсе де). Тек атаулар курс бетінде көрінеді.
    final unlocked = ref.watch(purchasedCoursesProvider).contains(course.id);
    if (!unlocked) {
      return _LockedLessonView(course: course, lesson: lesson, accent: accent);
    }

    final slides = _slidesFor(lesson);
    final pageCount = slides.length + 1; // +тест
    final isQuiz = _page == slides.length;

    final done = ref.watch(courseDoneCountProvider(course.id));
    final total = course.lessonCount;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        elevation: 0,
        title: Text(l.course_back_to_lessons, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.midnight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('🕵️ ${l.course_solved(done, total)}',
                    style: AppTypography.label(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero — барлық слайдта көрінеді.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _Hero(lesson: lesson, accent: accent),
          ),
          // Нүкте-индикатор.
          _Dots(count: pageCount, active: _page, accent: accent),
          const SizedBox(height: 12),
          // Слайдтар.
          Expanded(
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (p) => setState(() => _page = p),
              itemCount: pageCount,
              itemBuilder: (_, p) {
                if (p == slides.length) {
                  return _QuizPage(
                    quiz: lesson.quiz,
                    accent: accent,
                    selected: _selected,
                    submitted: _submitted,
                    onSelect: _submitted ? null : (i) => setState(() => _selected = i),
                  );
                }
                return _SlidePage(blocks: slides[p]);
              },
            ),
          ),
          // Төменгі навигация.
          _BottomNav(
            l: l,
            accent: accent,
            page: _page,
            pageCount: pageCount,
            isQuiz: isQuiz,
            quizSelected: _selected != null,
            quizSubmitted: _submitted,
            quizCorrect: _submitted && _selected == lesson.quiz.correctIndex,
            hasNextLesson: next != null,
            onPrev: () => _pc.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
            onNext: () => _pc.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
            onSubmit: () => setState(() => _submitted = true),
            onRetry: () => setState(() {
              _submitted = false;
              _selected = null;
            }),
            onFinish: () {
              ref.read(courseProgressProvider.notifier).markDone(lesson.id);
              // Backend синхрондау (best-effort).
              ref.read(apiServiceProvider).completeLesson(course.id, lesson.id).catchError((_) {});
              if (next != null) {
                // Келесі сабаққа — күйді тазалап ауысамыз.
                context.pushReplacement('/academy/course/${course.id}/lesson/${next.id}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.course_completed_all)),
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Hero карточкасы ──
class _Hero extends StatelessWidget {
  const _Hero({required this.lesson, required this.accent});
  final CourseLesson lesson;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 10),
          Text(lesson.title, style: AppTypography.h2().copyWith(height: 1.15)),
          if (lesson.hook.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(lesson.hook, style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.35)),
          ],
        ],
      ),
    );
  }
}

// ── Нүкте-индикатор ──
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active, required this.accent});
  final int count;
  final int active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active ? accent : accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

// ── Бір контент слайды ──
class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.blocks});
  final List<LessonBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final b in blocks) ...[
            _BlockView(block: b),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Бір мазмұн блогын рендерлейді.
class _BlockView extends StatelessWidget {
  const _BlockView({required this.block});
  final LessonBlock block;

  @override
  Widget build(BuildContext context) {
    final b = block;
    if (b is ParagraphBlock) {
      return Text(b.text, style: AppTypography.bodyLarge(color: AppColors.textPrimary).copyWith(height: 1.5));
    }
    if (b is HeadingBlock) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(b.text, style: AppTypography.h2()),
      );
    }
    if (b is CalloutBlock) return _Callout(block: b);
    if (b is FormulaBlock) return _FormulaView(block: b);
    if (b is CardsBlock) return _CardsView(block: b);
    if (b is MediaRecBlock) return _MediaRecView(block: b);
    if (b is InteractiveBlock) return buildCourseInteractive(b.key);
    return const SizedBox.shrink();
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.block});
  final CalloutBlock block;

  @override
  Widget build(BuildContext context) {
    final (color, icon, defTitle) = switch (block.kind) {
      CalloutKind.essence => (AppColors.gold, Icons.lightbulb_outline, 'Суть'),
      CalloutKind.example => (AppColors.dxyBlue, Icons.article_outlined, 'Пример'),
      CalloutKind.rule => (AppColors.profitGreen, Icons.gavel, 'Правило'),
      CalloutKind.mechanic => (AppColors.purple, Icons.settings_suggest, 'Механика'),
      CalloutKind.warning => (AppColors.lossRed, Icons.warning_amber, 'Внимание'),
      CalloutKind.fact => (AppColors.oilRed, Icons.auto_awesome, '💡 Интересный факт'),
      CalloutKind.story => (AppColors.silverGray, Icons.menu_book, 'История'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(block.title ?? defTitle,
                    style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(block.text, style: AppTypography.bodyLarge(color: AppColors.textPrimary).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _FormulaView extends StatelessWidget {
  const _FormulaView({required this.block});
  final FormulaBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.midnight, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null) ...[
            Text(block.title!,
                style: AppTypography.label(color: Colors.white70).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 10),
          ],
          for (final line in block.lines)
            Text(
              line.isEmpty ? ' ' : line,
              style: AppTypography.price(size: 14, color: Colors.white).copyWith(height: 1.5, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }
}

/// Мини-карточкалар тізбегі (көлденең).
class _CardsView extends StatelessWidget {
  const _CardsView({required this.block});
  final CardsBlock block;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(block.title.toUpperCase(),
            style: AppTypography.label(color: AppColors.textMuted).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 10),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: block.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final it = block.items[i];
              return Container(
                width: 176,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 8),
                    Text(it.title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w800, height: 1.15)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(it.text,
                          style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.3),
                          overflow: TextOverflow.fade),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Тақырып бойынша фильм/сериал/кітап ұсынысы.
class _MediaRecView extends StatelessWidget {
  const _MediaRecView({required this.block});
  final MediaRecBlock block;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (block.kind) {
      MediaKind.film => (Icons.movie_outlined, '🎬 Фильм по теме', AppColors.oilRed),
      MediaKind.series => (Icons.live_tv_outlined, '📺 Сериал по теме', AppColors.purple),
      MediaKind.book => (Icons.menu_book_outlined, '📖 Книга по теме', AppColors.dxyBlue),
      MediaKind.doc => (Icons.videocam_outlined, '🎥 Документалка по теме', AppColors.profitGreen),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text(block.title, style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w800, height: 1.2)),
          if (block.meta != null) ...[
            const SizedBox(height: 2),
            Text(block.meta!, style: AppTypography.label(color: AppColors.textMuted)),
          ],
          const SizedBox(height: 8),
          Text(block.note, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

// ── Тест слайды ──
class _QuizPage extends StatelessWidget {
  const _QuizPage({
    required this.quiz,
    required this.accent,
    required this.selected,
    required this.submitted,
    required this.onSelect,
  });

  final QuizQuestion quiz;
  final Color accent;
  final int? selected;
  final bool submitted;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isCorrect = submitted && selected == quiz.correctIndex;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🎯', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(l.lesson_quiz_title.toUpperCase(),
                    style: AppTypography.label(color: accent).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 12),
            Text(quiz.question, style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 14),
            for (int i = 0; i < quiz.options.length; i++) ...[
              _OptionRow(
                text: quiz.options[i],
                state: _optionState(i),
                onTap: onSelect == null ? null : () => onSelect!(i),
              ),
              const SizedBox(height: 8),
            ],
            if (submitted) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isCorrect ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 16, color: isCorrect ? AppColors.profitGreen : AppColors.lossRed),
                        const SizedBox(width: 6),
                        Text(isCorrect ? l.lesson_quiz_correct : l.lesson_quiz_wrong,
                            style: AppTypography.bodyMedium(color: isCorrect ? AppColors.profitGreen : AppColors.lossRed)
                                .copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(quiz.explanation, style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(height: 1.4)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _OptState _optionState(int i) {
    if (!submitted) return selected == i ? _OptState.selected : _OptState.idle;
    if (i == quiz.correctIndex) return _OptState.correct;
    if (i == selected) return _OptState.wrong;
    return _OptState.idle;
  }
}

enum _OptState { idle, selected, correct, wrong }

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.text, required this.state, required this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, icon) = switch (state) {
      _OptState.idle => (AppColors.surfaceMuted, AppColors.border, null),
      _OptState.selected => (AppColors.gold.withValues(alpha: 0.1), AppColors.gold, Icons.radio_button_checked),
      _OptState.correct => (AppColors.profitGreen.withValues(alpha: 0.12), AppColors.profitGreen, Icons.check_circle),
      _OptState.wrong => (AppColors.lossRed.withValues(alpha: 0.1), AppColors.lossRed, Icons.cancel),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon ?? Icons.radio_button_unchecked, size: 18, color: border == AppColors.border ? AppColors.textMuted : border),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppTypography.bodyMedium().copyWith(height: 1.3))),
          ],
        ),
      ),
    );
  }
}

// ── Төменгі навигация ──
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.l,
    required this.accent,
    required this.page,
    required this.pageCount,
    required this.isQuiz,
    required this.quizSelected,
    required this.quizSubmitted,
    required this.quizCorrect,
    required this.hasNextLesson,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
    required this.onRetry,
    required this.onFinish,
  });

  final AppLocalizations l;
  final Color accent;
  final int page;
  final int pageCount;
  final bool isQuiz;
  final bool quizSelected;
  final bool quizSubmitted;
  final bool quizCorrect;
  final bool hasNextLesson;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final VoidCallback onRetry;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final showBack = page > 0;

    // Оң жақ басты батырма.
    Widget primary;
    if (!isQuiz) {
      primary = _PrimaryBtn(label: l.course_next, icon: Icons.arrow_forward, accent: accent, onTap: onNext);
    } else if (!quizSubmitted) {
      primary = _PrimaryBtn(
        label: '${l.quiz_answer_cta} ☝️',
        accent: accent,
        onTap: quizSelected ? onSubmit : null,
      );
    } else if (quizCorrect) {
      primary = _PrimaryBtn(
        label: hasNextLesson ? l.lesson_next : l.course_finish_lesson,
        icon: hasNextLesson ? Icons.arrow_forward : Icons.check_circle,
        accent: accent,
        onTap: onFinish,
      );
    } else {
      primary = _PrimaryBtn(label: l.quiz_try_again, icon: Icons.refresh, accent: AppColors.lossRed, onTap: onRetry);
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          children: [
            if (showBack) ...[
              _SecondaryBtn(label: l.course_prev, onTap: onPrev),
              const SizedBox(width: 12),
            ],
            Expanded(child: primary),
          ],
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.accent, required this.onTap, this.icon});
  final String label;
  final Color accent;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? accent : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: AppTypography.button(color: enabled ? Colors.white : AppColors.textMuted).copyWith(fontSize: 16)),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: enabled ? Colors.white : AppColors.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  const _SecondaryBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.button(color: AppColors.textSecondary).copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// Сатып алмаған пайдаланушыға көрінетін құлып экраны (контент жасырын).
class _LockedLessonView extends ConsumerWidget {
  const _LockedLessonView({required this.course, required this.lesson, required this.accent});
  final Course course;
  final CourseLesson lesson;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(lesson.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text(lesson.title, textAlign: TextAlign.center, style: AppTypography.h2().copyWith(height: 1.2)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 18, color: accent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(l.course_locked_screen_hint,
                          style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  onPressed: () => showCourseUnlockSheet(context, ref, course),
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: Text(l.course_unlock_for(course.priceBonus)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

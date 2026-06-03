import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/lesson.dart';

class LessonPreview extends StatelessWidget {
  const LessonPreview({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/academy/lesson/${lesson.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school_outlined, color: AppColors.purple, size: 18),
                  const SizedBox(width: 6),
                  Text(l.home_lesson_preview, style: AppTypography.label(color: AppColors.purple)),
                  const Spacer(),
                  Text('+${lesson.xp} XP', style: AppTypography.label(color: AppColors.purple)),
                ],
              ),
              const SizedBox(height: 8),
              Text(lesson.title, style: AppTypography.h2()),
              const SizedBox(height: 4),
              Text(lesson.sourceName, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(
                lesson.explanation,
                style: AppTypography.bodySmall(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

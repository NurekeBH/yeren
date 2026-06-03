import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../profile/application/profile_controller.dart';

class GallupResultScreen extends ConsumerWidget {
  const GallupResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final result = ref.watch(profileControllerProvider).gallup;

    if (result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/academy');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final (name, desc) = _label(result.dominant, l);
    final total = result.scores.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: Text(result.dominant.emoji, style: const TextStyle(fontSize: 72))),
          const SizedBox(height: 12),
          Center(child: Text(l.gallup_result_title, style: AppTypography.label(color: AppColors.purple))),
          const SizedBox(height: 6),
          Center(child: Text(name, style: AppTypography.display())),
          const SizedBox(height: 12),
          Text(desc, style: AppTypography.bodyMedium(), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          for (final entry in result.scores.entries)
            _ScoreBar(profile: entry.key, score: entry.value, total: total == 0 ? 1 : total, l: l),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/academy'),
            child: Text(l.gallup_view_lessons),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.profile, required this.score, required this.total, required this.l});

  final GallupProfile profile;
  final int score;
  final int total;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (label, _) = _label(profile, l);
    final pct = score / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(profile.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: AppTypography.bodyMedium())),
              Text('${(pct * 100).toStringAsFixed(0)}%', style: AppTypography.label(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

(String, String) _label(GallupProfile p, AppLocalizations l) {
  switch (p) {
    case GallupProfile.revenge:
      return (l.gallup_profile_revenge, l.gallup_profile_revenge_desc);
    case GallupProfile.uncontrolledRisk:
      return (l.gallup_profile_risk, l.gallup_profile_risk_desc);
    case GallupProfile.hope:
      return (l.gallup_profile_hope, l.gallup_profile_hope_desc);
    case GallupProfile.disciplined:
      return (l.gallup_profile_disciplined, l.gallup_profile_disciplined_desc);
  }
}

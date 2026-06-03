import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../profile/application/profile_controller.dart';
import '../data/lessons_repository.dart';

class GallupTestScreen extends ConsumerStatefulWidget {
  const GallupTestScreen({super.key});

  @override
  ConsumerState<GallupTestScreen> createState() => _GallupTestScreenState();
}

class _GallupTestScreenState extends ConsumerState<GallupTestScreen> {
  final _answers = <GallupOption>[];

  void _selectOption(GallupOption option, List<GallupQuestion> questions) {
    setState(() => _answers.add(option));
    if (_answers.length >= questions.length) {
      final result = GallupResult.fromAnswers(_answers);
      ref.read(profileControllerProvider.notifier).setGallup(result);
      context.go('/academy/test/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(gallupQuestionsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.common_error}: $e')),
        data: (questions) {
          final i = _answers.length;
          if (i >= questions.length) return const SizedBox.shrink();
          final q = questions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.gallup_q_progress(i + 1, questions.length), style: AppTypography.label(color: AppColors.purple)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (i + 1) / questions.length,
                  backgroundColor: AppColors.border,
                  color: AppColors.purple,
                ),
                const SizedBox(height: 24),
                Text(q.text, style: AppTypography.h1()),
                const SizedBox(height: 24),
                for (final option in q.options) ...[
                  _OptionTile(label: option.label, onTap: () => _selectOption(option, questions)),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.bodyMedium())),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

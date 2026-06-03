import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/ticker_provider.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/calendar_event.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../calendar/data/calendar_repository.dart';

/// Home-да экономикалық календарь модулі: ең жақын 3 оқиға + толық экранға өту.
class CalendarModule extends ConsumerWidget {
  const CalendarModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(calendarEventsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note, color: AppColors.lossRed, size: 18),
                const SizedBox(width: 6),
                Text(l.calendar_title, style: AppTypography.label(color: AppColors.lossRed)),
                const Spacer(),
                IconButton(
                  tooltip: l.home_intel_open_full,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  onPressed: () => context.push('/calendar'),
                ),
              ],
            ),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Text('${l.common_error}: $e', style: AppTypography.bodySmall()),
              data: (events) {
                final upcoming = events
                    .where((e) => e.scheduledAt.isAfter(DateTime.now()) || e.scheduledAt.difference(DateTime.now()).inMinutes > -60)
                    .take(3)
                    .toList();
                if (upcoming.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l.calendar_empty, style: AppTypography.bodySmall()),
                  );
                }
                return Column(
                  children: [for (final e in upcoming) _EventRow(event: e, l: l)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends ConsumerWidget {
  const _EventRow({required this.event, required this.l});

  final CalendarEvent event;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(secondTickerProvider); // әр секунд rebuild — countdown live болсын
    final color = switch (event.impact) {
      ImpactLevel.low => AppColors.profitGreen,
      ImpactLevel.medium => AppColors.gold,
      ImpactLevel.high => AppColors.lossRed,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(event.currency, style: AppTypography.label(color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(event.impact.name.toUpperCase(), style: AppTypography.label(color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(event.name, style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(
            event.scheduledAt.isAfter(DateTime.now()) ? Fmt.countdown(event.countdown) : '—',
            style: AppTypography.price(size: 12, color: color),
          ),
        ],
      ),
    );
  }
}

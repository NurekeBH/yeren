import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/ticker_provider.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/calendar_event.dart';
import '../../../../shared/widgets/error_view.dart';
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
              error: (e, _) => ErrorRetryView(
                error: e,
                compact: true,
                onRetry: () => ref.invalidate(calendarEventsProvider),
              ),
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

// Импакт түстері — апп палитрасы (толық календарь экранымен бірдей).
Color _impactColor(ImpactLevel l) => switch (l) {
      ImpactLevel.low => AppColors.profitGreen,
      ImpactLevel.medium => AppColors.gold,
      ImpactLevel.high => AppColors.lossRed,
    };

String _fromNow(Duration d, AppLocalizations l) {
  if (d.isNegative) return l.calendar_released;
  if (d.inMinutes < 1) return l.calendar_soon;
  if (d.inHours < 1) return l.calendar_in_m(d.inMinutes);
  return l.calendar_in_h(d.inHours);
}

class _EventRow extends ConsumerWidget {
  const _EventRow({required this.event, required this.l});

  final CalendarEvent event;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(secondTickerProvider); // әр секунд rebuild — countdown live болсын
    final color = _impactColor(event.impact);
    final time = '${event.scheduledAt.hour.toString().padLeft(2, '0')}:${event.scheduledAt.minute.toString().padLeft(2, '0')}';
    final imminent = !event.countdown.isNegative && event.countdown.inMinutes < 60;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          // Уақыт
          Text(time, style: AppTypography.price(size: 14, weight: FontWeight.w700)),
          const SizedBox(width: 10),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${event.currency} ${event.name}',
                    style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 11, color: imminent ? color : AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(_fromNow(event.countdown, l),
                        style: AppTypography.label(color: imminent ? color : AppColors.textMuted)
                            .copyWith(fontWeight: imminent ? FontWeight.w700 : FontWeight.w500)),
                    if (event.forecast != null) ...[
                      const SizedBox(width: 8),
                      Text('${l.calendar_forecast_short} ${event.forecast}',
                          style: AppTypography.label(color: AppColors.dxyBlue).copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

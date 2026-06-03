import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/ticker_provider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/calendar_event.dart';
import '../../../shared/utils/formatters.dart';
import '../data/calendar_repository.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  ImpactLevel? _filter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.calendar_title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: l.calendar_filter_all, selected: _filter == null, color: AppColors.textSecondary, onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l.calendar_filter_low, selected: _filter == ImpactLevel.low, color: AppColors.profitGreen, onTap: () => setState(() => _filter = ImpactLevel.low)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l.calendar_filter_medium, selected: _filter == ImpactLevel.medium, color: AppColors.gold, onTap: () => setState(() => _filter = ImpactLevel.medium)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l.calendar_filter_high, selected: _filter == ImpactLevel.high, color: AppColors.lossRed, onTap: () => setState(() => _filter = ImpactLevel.high)),
                ],
              ),
            ),
          ),
          const _HeaderRow(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l.common_error}: $e')),
              data: (events) {
                final filtered = _filter == null ? events : events.where((e) => e.impact == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l.calendar_empty, style: AppTypography.bodyMedium()));
                }
                final grouped = _groupByDay(filtered);
                final keys = grouped.keys.toList()..sort();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
                  itemCount: keys.length,
                  itemBuilder: (_, i) {
                    final day = keys[i];
                    final items = grouped[day]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DayHeader(date: day),
                        for (final e in items) _EventRow(event: e, l: l),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<CalendarEvent>> _groupByDay(List<CalendarEvent> events) {
    final map = <DateTime, List<CalendarEvent>>{};
    for (final e in events) {
      final day = DateTime(e.scheduledAt.year, e.scheduledAt.month, e.scheduledAt.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    }
    return map;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.color, required this.onTap});

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.label(color: selected ? color : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text('Time', style: AppTypography.label(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('Cur', style: AppTypography.label(color: AppColors.textMuted))),
          const SizedBox(width: 12),
          Expanded(child: Text('Event', style: AppTypography.label(color: AppColors.textMuted))),
          SizedBox(width: 60, child: Text(l.calendar_actual, style: AppTypography.label(color: AppColors.textMuted), textAlign: TextAlign.right)),
          const SizedBox(width: 6),
          SizedBox(width: 60, child: Text(l.calendar_forecast, style: AppTypography.label(color: AppColors.textMuted), textAlign: TextAlign.right)),
          const SizedBox(width: 6),
          SizedBox(width: 60, child: Text(l.calendar_previous, style: AppTypography.label(color: AppColors.textMuted), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    final String label;
    if (diff == 0) {
      label = 'Today, ${_fmt(date)}';
    } else if (diff == 1) {
      label = 'Tomorrow, ${_fmt(date)}';
    } else {
      label = '${_weekday(date.weekday)}, ${_fmt(date)}';
    }
    return Container(
      width: double.infinity,
      color: AppColors.midnight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label(color: AppColors.goldBright),
      ),
    );
  }

  static String _fmt(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  static String _weekday(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1).clamp(0, 6)];
  }
}

class _EventRow extends ConsumerWidget {
  const _EventRow({required this.event, required this.l});

  final CalendarEvent event;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(secondTickerProvider); // әр секунд rebuild — live countdown
    final color = switch (event.impact) {
      ImpactLevel.low => AppColors.profitGreen,
      ImpactLevel.medium => AppColors.gold,
      ImpactLevel.high => AppColors.lossRed,
    };

    final time = '${event.scheduledAt.hour.toString().padLeft(2, '0')}:${event.scheduledAt.minute.toString().padLeft(2, '0')}';
    final isUpcoming = event.scheduledAt.isAfter(DateTime.now());
    final isImminent = isUpcoming && event.countdown.inMinutes < 60;

    return InkWell(
      onTap: () => _showEventDetail(context, event, l, color),
      child: Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 56,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time, style: AppTypography.price(size: 13, weight: FontWeight.w600)),
                      if (isImminent)
                        Text(Fmt.countdown(event.countdown),
                            style: AppTypography.label(color: AppColors.lossRed)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(event.currency, style: AppTypography.price(size: 13, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                // Impact pills (3 dots)
                _ImpactDots(level: event.impact),
                const SizedBox(width: 8),
                Expanded(child: Text(event.name, style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w600))),
                SizedBox(
                  width: 60,
                  child: Text(
                    event.actual ?? '—',
                    textAlign: TextAlign.right,
                    style: AppTypography.price(size: 12, weight: FontWeight.w700, color: event.actual != null ? color : AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 60,
                  child: Text(
                    event.forecast ?? '—',
                    textAlign: TextAlign.right,
                    style: AppTypography.price(size: 12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 60,
                  child: Text(
                    event.previous ?? '—',
                    textAlign: TextAlign.right,
                    style: AppTypography.price(size: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            if (event.goldImpactNote != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 64),
                child: Row(
                  children: [
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(event.goldImpactNote!, style: AppTypography.label(color: AppColors.gold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImpactDots extends StatelessWidget {
  const _ImpactDots({required this.level});

  final ImpactLevel level;

  @override
  Widget build(BuildContext context) {
    final filled = switch (level) {
      ImpactLevel.low => 1,
      ImpactLevel.medium => 2,
      ImpactLevel.high => 3,
    };
    final color = switch (level) {
      ImpactLevel.low => AppColors.profitGreen,
      ImpactLevel.medium => AppColors.gold,
      ImpactLevel.high => AppColors.lossRed,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isFilled ? color : AppColors.border,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

void _showEventDetail(BuildContext context, CalendarEvent event, AppLocalizations l, Color color) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(event.currency, style: AppTypography.label(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(event.impact.name.toUpperCase(), style: AppTypography.label(color: color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(event.name, style: AppTypography.h1()),
          const SizedBox(height: 8),
          Text(
            '${event.scheduledAt.day}/${event.scheduledAt.month}/${event.scheduledAt.year}  '
            '${event.scheduledAt.hour.toString().padLeft(2, '0')}:'
            '${event.scheduledAt.minute.toString().padLeft(2, '0')}',
            style: AppTypography.price(size: 14, color: AppColors.textSecondary),
          ),
          if (event.scheduledAt.isAfter(DateTime.now())) ...[
            const SizedBox(height: 8),
            Text(
              Fmt.countdown(event.countdown),
              style: AppTypography.price(size: 22, weight: FontWeight.w700, color: color),
            ),
          ],
          const Divider(height: 24),
          _DetailRow(label: l.calendar_forecast, value: event.forecast ?? '—'),
          _DetailRow(label: l.calendar_previous, value: event.previous ?? '—'),
          _DetailRow(label: l.calendar_actual, value: event.actual ?? '—'),
          if (event.goldImpactNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.goldImpactNote!, style: AppTypography.bodySmall(color: AppColors.gold))),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
          Text(value, style: AppTypography.price(size: 14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

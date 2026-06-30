import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/ticker_provider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/calendar_event.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/calendar_repository.dart';

// Импакт түстері — апп палитрасы (төмен=жасыл, орташа=алтын, жоғары=қызыл).
Color _impactColor(ImpactLevel l) => switch (l) {
      ImpactLevel.low => AppColors.profitGreen,
      ImpactLevel.medium => AppColors.gold,
      ImpactLevel.high => AppColors.lossRed,
    };

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  ImpactLevel? _filter;

  @override
  void initState() {
    super.initState();
    // BI: экономкалендарь ашылды (feature adoption).
    ref.read(apiServiceProvider).track('view_calendar');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.calendar_title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: l.calendar_filter_all, selected: _filter == null, color: AppColors.textSecondary, onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l.calendar_filter_low, selected: _filter == ImpactLevel.low, color: _impactColor(ImpactLevel.low), onTap: () => setState(() => _filter = ImpactLevel.low)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l.calendar_filter_medium, selected: _filter == ImpactLevel.medium, color: _impactColor(ImpactLevel.medium), onTap: () => setState(() => _filter = ImpactLevel.medium)),
                  const SizedBox(width: 8),
                  _FilterChip(label: l.calendar_filter_high, selected: _filter == ImpactLevel.high, color: _impactColor(ImpactLevel.high), onTap: () => setState(() => _filter = ImpactLevel.high)),
                ],
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(calendarEventsProvider)),
              data: (events) {
                final filtered = _filter == null ? events : events.where((e) => e.impact == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l.calendar_empty, style: AppTypography.bodyMedium()));
                }
                final grouped = _groupByDay(filtered);
                final keys = grouped.keys.toList()..sort();
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: keys.length,
                  itemBuilder: (_, i) {
                    final day = keys[i];
                    final items = grouped[day]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DayHeader(date: day, events: items),
                        for (final e in items) _EventCard(event: e, l: l),
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

String _fromNow(Duration d, AppLocalizations l) {
  if (d.isNegative) return l.calendar_released;
  if (d.inMinutes < 1) return l.calendar_soon;
  if (d.inHours < 1) return l.calendar_in_m(d.inMinutes);
  return l.calendar_in_h(d.inHours);
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

/// Күн тақырыбы — күн + импакт саны (сары/қызғылт сары/қызыл).
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.events});

  final DateTime date;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    final l = AppLocalizations.of(context);
    final String label;
    if (diff == 0) {
      label = '${l.calendar_today}, ${_fmt(date)}';
    } else if (diff == 1) {
      label = '${l.calendar_tomorrow}, ${_fmt(date)}';
    } else {
      label = '${_weekday(date.weekday)}, ${_fmt(date)}';
    }
    final low = events.where((e) => e.impact == ImpactLevel.low).length;
    final med = events.where((e) => e.impact == ImpactLevel.medium).length;
    final high = events.where((e) => e.impact == ImpactLevel.high).length;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w700)),
          ),
          _CountChip(color: _impactColor(ImpactLevel.low), count: low),
          const SizedBox(width: 12),
          _CountChip(color: _impactColor(ImpactLevel.medium), count: med),
          const SizedBox(width: 12),
          _CountChip(color: _impactColor(ImpactLevel.high), count: high),
        ],
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

class _CountChip extends StatelessWidget {
  const _CountChip({required this.color, required this.count});
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$count', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Оқиға карточкасы — референске сай: уақыт + countdown, импакт, валюта+атау, PREV/FORE, mini-график.
class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event, required this.l});

  final CalendarEvent event;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ПЕРФОРМАНС: ticker-ді бүкіл карточка ЕМЕС, тек countdown чипі қана watch етеді
    // (төменгі Consumer). Әйтпесе ауыр _MiniBars painter де секунд-сайын rebuild болатын.
    final color = _impactColor(event.impact);
    final time = '${event.scheduledAt.hour.toString().padLeft(2, '0')}:${event.scheduledAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showEventDetail(context, event, l, color),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: color), // импакт акценті
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Уақыт + countdown
                        Row(
                          children: [
                            Text(time, style: AppTypography.price(size: 16, weight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            // Тек осы чип секунд-сайын rebuild болады (қалған карточка тұрақты).
                            Consumer(
                              builder: (context, ref, _) {
                                ref.watch(secondTickerProvider);
                                final imminent = !event.countdown.isNegative && event.countdown.inMinutes < 60;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: imminent ? color.withValues(alpha: 0.14) : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule, size: 12, color: imminent ? color : AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(_fromNow(event.countdown, l),
                                          style: AppTypography.label(color: imminent ? color : AppColors.textSecondary)
                                              .copyWith(fontWeight: imminent ? FontWeight.w700 : FontWeight.w500)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Импакт нүктесі + валюта + атау
                        Row(
                          children: [
                            Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${event.currency} ${event.name}',
                                  style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700, height: 1.2),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // PREV / FORE / ACTUAL
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (event.previous != null) _DataChip(label: l.calendar_previous_short, value: event.previous!),
                            if (event.forecast != null) _DataChip(label: l.calendar_forecast_short, value: event.forecast!),
                            if (event.actual != null) _DataChip(label: l.calendar_actual_short, value: event.actual!, color: color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Mini-график
                Padding(
                  padding: const EdgeInsets.only(right: 14, left: 4),
                  child: Center(child: _MiniBars(seed: event.id, color: color)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// PREV / FORE / ACT чипі.
class _DataChip extends StatelessWidget {
  const _DataChip({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.dxyBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text(value, style: AppTypography.price(size: 13, weight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}

/// Шағын баған-график (детерминалды, id-ден) — референстегідей.
class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.seed, required this.color});
  final String seed;
  final Color color;

  static const double width = 64;
  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    var h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    const n = 11;
    final bars = List.generate(n, (i) {
      final v = ((h >> (i % 28)) % 100) / 100.0;
      return 0.25 + v * 0.75; // 0.25..1.0
    });
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < n; i++)
            Container(
              width: (width / n) - 1.5,
              height: height * bars[i],
              decoration: BoxDecoration(
                color: color.withValues(alpha: i.isEven ? 0.85 : 0.45),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
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

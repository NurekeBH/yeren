import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../data/journal_controller.dart';
import '../data/journal_models.dart';

/// Аналитика табы: Win Rate / Profit Factor / EV + P&L күнтізбесі (GitHub-стиль) +
/// «Эмоция vs Пайда» матрицасы + setup/session бөліністері.
class JournalAnalyticsTab extends ConsumerWidget {
  const JournalAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(journalAnalyticsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.common_error}: $e')),
      data: (a) {
        if (a.isEmpty) {
          return _Empty(label: l.journal_analytics_empty);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(journalAnalyticsProvider);
            await ref.read(journalAnalyticsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _StatGrid(a: a),
              const SizedBox(height: 20),
              Text(l.journal_calendar_title, style: AppTypography.h2()),
              const SizedBox(height: 10),
              _CalendarHeatmap(cells: a.calendar),
              const SizedBox(height: 20),
              Text(l.journal_emotions_title, style: AppTypography.h2()),
              const SizedBox(height: 10),
              _EmotionsCard(a: a, l: l),
              if (a.setups.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(l.journal_setups_title, style: AppTypography.h2()),
                const SizedBox(height: 10),
                _Breakdown(rows: a.setups),
              ],
              if (a.sessions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(l.journal_sessions_title, style: AppTypography.h2()),
                const SizedBox(height: 10),
                _Breakdown(rows: a.sessions),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _money(double v) {
  final s = v.abs().toStringAsFixed(2);
  return '${v < 0 ? '-' : ''}\$$s';
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.a});
  final JournalAnalytics a;

  @override
  Widget build(BuildContext context) {
    final pf = a.profitFactor;
    final cards = [
      _Stat('Win Rate', '${(a.winRate * 100).toStringAsFixed(1)}%', AppColors.dxyBlue),
      _Stat('Profit Factor', pf == null ? '∞' : pf.toStringAsFixed(2),
          (pf ?? 99) >= 1 ? AppColors.profitGreen : AppColors.lossRed),
      _Stat('Net P&L', _money(a.netProfit), a.netProfit >= 0 ? AppColors.profitGreen : AppColors.lossRed),
      _Stat('Expectancy', _money(a.expectancy), a.expectancy >= 0 ? AppColors.profitGreen : AppColors.lossRed),
      _Stat('Сделок', '${a.closed}', AppColors.textPrimary),
      _Stat('W / L', '${a.wins} / ${a.losses}', AppColors.textPrimary),
      _Stat('Avg Win', _money(a.avgWin), AppColors.profitGreen),
      _Stat('Avg Loss', _money(a.avgLoss), AppColors.lossRed),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: cards,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.price(size: 19, weight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

/// GitHub-стиль P&L жылулық торы — соңғы 15 апта × 7 күн.
class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({required this.cells});
  final List<CalendarCell> cells;

  @override
  Widget build(BuildContext context) {
    final byDay = <String, CalendarCell>{
      for (final c in cells) _key(c.day): c,
    };
    final today = DateTime.now();
    // Аптаның басына (дүйсенбі) туралау.
    final start = today.subtract(Duration(days: today.weekday - 1 + 14 * 7));
    const weeks = 15;

    double maxAbs = 1;
    for (final c in cells) {
      if (c.pnl.abs() > maxAbs) maxAbs = c.pnl.abs();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int row = 0; row < 7; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  for (int w = 0; w < weeks; w++)
                    Builder(builder: (_) {
                      final day = start.add(Duration(days: w * 7 + row));
                      if (day.isAfter(today)) return const SizedBox(width: 17);
                      final cell = byDay[_key(day)];
                      return Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _cellColor(cell, maxAbs),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Color _cellColor(CalendarCell? c, double maxAbs) {
    if (c == null || c.trades == 0) return AppColors.surfaceMuted;
    final intensity = (c.pnl.abs() / maxAbs).clamp(0.18, 1.0);
    final base = c.pnl >= 0 ? AppColors.profitGreen : AppColors.lossRed;
    return base.withValues(alpha: intensity);
  }
}

class _EmotionsCard extends StatelessWidget {
  const _EmotionsCard({required this.a, required this.l});
  final JournalAnalytics a;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (a.emotions.isEmpty) {
      return _CardBox(child: Text(l.journal_analytics_empty, style: AppTypography.bodySmall(color: AppColors.textSecondary)));
    }
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.emotionCorr != null) ...[
            Row(
              children: [
                Text('${l.journal_correlation}: ', style: AppTypography.label(color: AppColors.textSecondary)),
                Text(a.emotionCorr!.toStringAsFixed(2),
                    style: AppTypography.price(
                      size: 14,
                      weight: FontWeight.w700,
                      color: a.emotionCorr! >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                    )),
              ],
            ),
            const Divider(height: 18),
          ],
          for (final e in a.emotions) ...[
            Row(
              children: [
                Text(e.emotion, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${e.trades} сделок · ${(e.winRate * 100).round()}% WR',
                      style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                ),
                Text(_money(e.pnl),
                    style: AppTypography.price(
                      size: 14,
                      weight: FontWeight.w700,
                      color: e.pnl >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                    )),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.rows});
  final List<TagStat> rows;
  @override
  Widget build(BuildContext context) {
    return _CardBox(
      child: Column(
        children: [
          for (final r in rows) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(r.key, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('${r.trades} · ${(r.winRate * 100).round()}%',
                      style: AppTypography.label(color: AppColors.textSecondary)),
                ),
                Text(_money(r.pnl),
                    style: AppTypography.price(
                      size: 13,
                      weight: FontWeight.w700,
                      color: r.pnl >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                    )),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.insights_outlined, size: 56, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(label, textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
      ],
    );
  }
}

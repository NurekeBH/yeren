import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../application/admin_dashboard_controllers.dart';

/// BI-дашборд админа (Flutter / Flutter-Web / планшет). Данные — живые
/// /admin/bi/* эндпоинты. Требует вход под админ-аккаунтом (admin JWT).
/// Управление состоянием — Riverpod: смена [dashboardPeriodProvider] авто-рефетчит
/// зависимые провайдеры (см. _PeriodFilter).
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(title: const Text('BI Dashboard'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          // Принудительно обновить все блоки.
          ref.invalidate(biOverviewProvider);
          ref.invalidate(biRevenueProvider);
          ref.invalidate(biSignalsDeepProvider);
          ref.invalidate(biFeatureProvider);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Адаптив: на широком экране (Web/планшет) — многоколоночная сетка.
            final wide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 14, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PeriodFilter(),
                      const SizedBox(height: 16),
                      _SummaryBlock(wide: wide),
                      const SizedBox(height: 24),
                      _ChartsBlock(wide: wide),
                      const SizedBox(height: 24),
                      _TablesBlock(wide: wide),
                      const SizedBox(height: 24),
                      const _FeatureBlock(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────── helpers ───────────────
num _n(dynamic v) => v is num ? v : num.tryParse('${v ?? 0}') ?? 0;
String _money(num v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '$b ₸';
}

// ─────────────── Дата-фильтр (управление состоянием) ───────────────
class _PeriodFilter extends ConsumerWidget {
  const _PeriodFilter();

  static const _opts = [('day', 'Сегодня'), ('week', '7 дней'), ('month', '30 дней')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(dashboardPeriodProvider);
    return Wrap(
      spacing: 8,
      children: [
        for (final (value, label) in _opts)
          ChoiceChip(
            label: Text(label),
            selected: period == value,
            // Смена фильтра → StateProvider → авто-рефетч biRevenueProvider.
            onSelected: (_) => ref.read(dashboardPeriodProvider.notifier).state = value,
            selectedColor: AppColors.gold,
            labelStyle: TextStyle(
              color: period == value ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
      ],
    );
  }
}

// ─────────────── Блок 1: Summary Cards ───────────────
class _SummaryBlock extends ConsumerWidget {
  const _SummaryBlock({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rev = ref.watch(biRevenueProvider);
    final ov = ref.watch(biOverviewProvider);
    final feat = ref.watch(biFeatureProvider);

    final revM = rev.valueOrNull ?? const {};
    final sub = (revM['subscription'] as Map?) ?? const {};
    final sig = (revM['signals'] as Map?) ?? const {};
    final subRev = _n(sub['revenue']);
    final sigRev = _n(sig['revenue']);
    final total = subRev + sigRev;
    final sigPct = total > 0 ? (sigRev / total * 100).round() : 0;
    final dau = _n(ov.valueOrNull?['dau']);
    final alerts = _n((feat.valueOrNull?['price_alerts'] as Map?)?['total_alerts']);

    final cards = [
      _SummaryCard(
        label: 'Общий доход',
        value: _money(total),
        hint: 'Сигналы $sigPct% · Подписки ${100 - sigPct}%',
        color: AppColors.gold,
        loading: rev.isLoading,
      ),
      _SummaryCard(
        label: 'Продано сигналов',
        value: _n(sig['purchases']).toString(),
        hint: 'за период',
        color: AppColors.dxyBlue,
        loading: rev.isLoading,
      ),
      _SummaryCard(
        label: 'DAU',
        value: dau.toString(),
        hint: 'активных сегодня',
        color: AppColors.profitGreen,
        loading: ov.isLoading,
      ),
      _SummaryCard(
        label: 'Будильников цены',
        value: alerts.toString(),
        hint: 'запущено всего',
        color: AppColors.goldBright,
        loading: feat.isLoading,
      ),
    ];

    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: wide ? 1.7 : 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: cards,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.hint, required this.color, this.loading = false});
  final String label;
  final String value;
  final String hint;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTypography.label(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          loading
              ? const SizedBox(height: 26, width: 26, child: CircularProgressIndicator(strokeWidth: 2))
              : FittedBox(child: Text(value, style: AppTypography.price(size: 24, weight: FontWeight.w800, color: color))),
          const SizedBox(height: 4),
          Text(hint, style: AppTypography.label(color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─────────────── Блок 2: Charts ───────────────
class _ChartsBlock extends ConsumerWidget {
  const _ChartsBlock({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rev = ref.watch(biRevenueProvider);
    final bar = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Покупки по дням: 500 vs 1000', style: AppTypography.h2().copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          SizedBox(height: 200, child: rev.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('—')),
            data: (m) => _TierBarChart(series: (m['series'] as List?) ?? const []),
          )),
          const SizedBox(height: 8),
          Row(children: const [
            _Legend(color: AppColors.dxyBlue, text: '500 бонусов'),
            SizedBox(width: 16),
            _Legend(color: AppColors.goldBright, text: '1000 бонусов'),
          ]),
        ],
      ),
    );
    final pie = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Доля выручки', style: AppTypography.h2().copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          SizedBox(height: 200, child: rev.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('—')),
            data: (m) => _RevenuePie(
              sub: _n((m['subscription'] as Map?)?['revenue']),
              sig: _n((m['signals'] as Map?)?['revenue']),
            ),
          )),
          const SizedBox(height: 8),
          Row(children: const [
            _Legend(color: AppColors.gold, text: 'Разовые сигналы'),
            SizedBox(width: 16),
            _Legend(color: AppColors.profitGreen, text: 'Подписки'),
          ]),
        ],
      ),
    );

    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: bar),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: pie),
      ]);
    }
    return Column(children: [bar, const SizedBox(height: 16), pie]);
  }
}

class _TierBarChart extends StatelessWidget {
  const _TierBarChart({required this.series});
  final List<dynamic> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const Center(child: Text('Нет данных'));
    final maxY = series.fold<double>(1, (m, s) {
      final a = _n(s['sig500']).toDouble();
      final b = _n(s['sig1000']).toDouble();
      return [m, a, b].reduce((x, y) => x > y ? x : y);
    });
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY * 1.2,
      barTouchData: BarTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            // Показываем не все подписи, чтобы не теснились.
            if (i < 0 || i >= series.length || (series.length > 8 && i % 2 != 0)) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${series[i]['label']}', style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 9)),
            );
          },
        )),
      ),
      barGroups: [
        for (var i = 0; i < series.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: _n(series[i]['sig500']).toDouble(), color: AppColors.dxyBlue, width: 6, borderRadius: BorderRadius.circular(2)),
            BarChartRodData(toY: _n(series[i]['sig1000']).toDouble(), color: AppColors.goldBright, width: 6, borderRadius: BorderRadius.circular(2)),
          ]),
      ],
    ));
  }
}

class _RevenuePie extends StatelessWidget {
  const _RevenuePie({required this.sub, required this.sig});
  final num sub;
  final num sig;

  @override
  Widget build(BuildContext context) {
    final total = (sub + sig).toDouble();
    if (total <= 0) return const Center(child: Text('Нет данных'));
    final subPct = (sub / total * 100).round();
    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 36,
      sections: [
        PieChartSectionData(
          value: sig.toDouble(), color: AppColors.gold, radius: 52,
          title: '${100 - subPct}%', titleStyle: AppTypography.button(color: Colors.white).copyWith(fontSize: 13),
        ),
        PieChartSectionData(
          value: sub.toDouble(), color: AppColors.profitGreen, radius: 52,
          title: '$subPct%', titleStyle: AppTypography.button(color: Colors.white).copyWith(fontSize: 13),
        ),
      ],
    ));
  }
}

// ─────────────── Блок 3: Tables (Whales + Traders) ───────────────
class _TablesBlock extends ConsumerWidget {
  const _TablesBlock({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deep = ref.watch(biSignalsDeepProvider);
    final whales = (deep.valueOrNull?['whales'] as List?) ?? const [];
    final traders = (deep.valueOrNull?['top_traders'] as List?) ?? const [];

    final whalesCard = _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🐋 Топ-плательщики', style: AppTypography.h2().copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        if (deep.isLoading) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (whales.isEmpty) Text('Покупок пока нет', style: AppTypography.bodySmall(color: AppColors.textMuted))
        else for (var i = 0; i < whales.length && i < 8; i++)
          _RankRow(
            rank: i,
            name: '${whales[i]['name'] ?? '—'}',
            value: _money(_n(whales[i]['spent'])),
            sub: '${_n(whales[i]['signals_bought'])} сигн.',
          ),
      ]),
    );

    final tradersCard = _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🏆 Топ-трейдеры', style: AppTypography.h2().copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        if (deep.isLoading) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (traders.isEmpty) Text('Продаж пока нет', style: AppTypography.bodySmall(color: AppColors.textMuted))
        else for (var i = 0; i < traders.length && i < 8; i++)
          _RankRow(
            rank: i,
            name: '${traders[i]['name'] ?? '—'}',
            value: _money(_n(traders[i]['revenue'])),
            sub: 'win ${(_n(traders[i]['win_rate']) * 100).round()}%'
                '${traders[i]['conversion_pct'] != null ? ' · конв. ${traders[i]['conversion_pct']}%' : ''}',
          ),
      ]),
    );

    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: whalesCard),
        const SizedBox(width: 16),
        Expanded(child: tradersCard),
      ]);
    }
    return Column(children: [whalesCard, const SizedBox(height: 16), tradersCard]);
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.name, required this.value, required this.sub});
  final int rank;
  final String name;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        SizedBox(width: 26, child: Text(rank < 3 ? medals[rank] : '${rank + 1}.', style: AppTypography.bodySmall())),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(sub, style: AppTypography.label(color: AppColors.textMuted)),
        ])),
        Text(value, style: AppTypography.price(size: 14, weight: FontWeight.w800, color: AppColors.gold)),
      ]),
    );
  }
}

// ─────────────── Блок 4: Feature audit ───────────────
class _FeatureBlock extends ConsumerWidget {
  const _FeatureBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feat = ref.watch(biFeatureProvider);
    final features = (feat.valueOrNull?['features'] as List?) ?? const [];
    final maxMau = features.fold<num>(1, (m, f) => _n(f['mau']) > m ? _n(f['mau']) : m);

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📊 Аудит функций (DAU / MAU)', style: AppTypography.h2().copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text('Цвет: 🟢 живая · 🟡 стабильно · 🔴 мало используют', style: AppTypography.label(color: AppColors.textMuted)),
        const SizedBox(height: 12),
        if (feat.isLoading) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (features.isEmpty) Text('Данные появятся после накопления активности', style: AppTypography.bodySmall(color: AppColors.textMuted))
        else for (final f in features)
          _FeatureRow(
            label: '${f['label'] ?? f['event']}',
            dau: _n(f['dau']).toInt(),
            mau: _n(f['mau']).toInt(),
            ratio: maxMau > 0 ? (_n(f['mau']) / maxMau).toDouble() : 0,
            health: '${f['health'] ?? 'ok'}',
          ),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label, required this.dau, required this.mau, required this.ratio, required this.health});
  final String label;
  final int dau;
  final int mau;
  final double ratio;
  final String health;

  @override
  Widget build(BuildContext context) {
    // 🔴 мало (health=low) · 🟡 стабильно (низкий ratio) · 🟢 растёт (высокий ratio).
    final (color, dot) = health == 'low'
        ? (AppColors.lossRed, '🔴')
        : ratio >= 0.5
            ? (AppColors.profitGreen, '🟢')
            : (const Color(0xFFD97706), '🟡');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Text(dot, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(label, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.02, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text('DAU $dau · MAU $mau', style: AppTypography.label(color: AppColors.textMuted), textAlign: TextAlign.right),
        ),
      ]),
    );
  }
}

// ─────────────── shared ───────────────
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(text, style: AppTypography.label(color: AppColors.textMuted)),
    ]);
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/provider_dashboard_controller.dart';

/// Кабинет трейдера: балансы, продажи сигналов/курсов, доход по периодам,
/// рефералы и история выплат. Данные — /provider/dashboard (requireTrader).
class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(providerDashboardProvider);
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(title: const Text('Кабинет трейдера'), elevation: 0),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(providerDashboardProvider)),
        data: (d) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(providerDashboardProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _BalanceBlock(balance: (d['balance'] as Map?) ?? const {}),
              const SizedBox(height: 20),
              const _PeriodFilter(),
              const SizedBox(height: 12),
              _IncomeBlock(income: (d['income'] as Map?) ?? const {}, trend: (d['trend'] as List?) ?? const []),
              const SizedBox(height: 20),
              _ReferralCard(ref: (d['referrals'] as Map?) ?? const {}),
              const SizedBox(height: 20),
              _SalesSection(
                title: '📈 Продажи сигналов',
                data: (d['signal_sales'] as Map?) ?? const {},
                labelOf: (it) => '${it['pair']} · ${it['direction']}',
              ),
              const SizedBox(height: 20),
              _SalesSection(
                title: '🎓 Продажи курсов',
                data: (d['course_sales'] as Map?) ?? const {},
                labelOf: (it) => '${it['title']}',
              ),
              const SizedBox(height: 20),
              _PayoutHistory(payouts: (d['payouts'] as List?) ?? const []),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────── helpers ───────────
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

// ─────────── Балансы ───────────
class _BalanceBlock extends StatelessWidget {
  const _BalanceBlock({required this.balance});
  final Map balance;

  @override
  Widget build(BuildContext context) {
    final available = _n(balance['available']);
    return Column(
      children: [
        // Главная карточка — доступно к выводу (премиум-градиент).
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.goldBright],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.28), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Доступно к выводу', style: AppTypography.label(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(_money(available), style: AppTypography.price(size: 34, weight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _MiniBalance(label: 'Общий заработок', value: _money(_n(balance['earned'])), color: AppColors.textPrimary)),
          const SizedBox(width: 12),
          Expanded(child: _MiniBalance(label: 'Уже выплачено', value: _money(_n(balance['paid'])), color: AppColors.profitGreen)),
        ]),
      ],
    );
  }
}

class _MiniBalance extends StatelessWidget {
  const _MiniBalance({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.label(color: AppColors.textMuted)),
      const SizedBox(height: 4),
      FittedBox(child: Text(value, style: AppTypography.price(size: 19, weight: FontWeight.w800, color: color))),
    ]));
  }
}

// ─────────── Период ───────────
class _PeriodFilter extends ConsumerWidget {
  const _PeriodFilter();
  static const _opts = [('day', 'День'), ('week', 'Неделя'), ('month', 'Месяц'), ('year', 'Год'), ('all', 'Всё время')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(providerPeriodProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final (value, label) in _opts)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: period == value,
              onSelected: (_) => ref.read(providerPeriodProvider.notifier).state = value,
              selectedColor: AppColors.gold,
              labelStyle: TextStyle(color: period == value ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600),
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
            ),
          ),
      ]),
    );
  }
}

// ─────────── Доход (период + тренд) ───────────
class _IncomeBlock extends StatelessWidget {
  const _IncomeBlock({required this.income, required this.trend});
  final Map income;
  final List trend;

  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _IncomeStat(label: 'Доход с сигналов', value: _money(_n(income['signals'])), color: AppColors.dxyBlue)),
        Expanded(child: _IncomeStat(label: 'Доход с курсов', value: _money(_n(income['courses'])), color: AppColors.goldBright)),
        Expanded(child: _IncomeStat(label: 'Итого', value: _money(_n(income['total'])), color: AppColors.profitGreen)),
      ]),
      const SizedBox(height: 16),
      Text('Тренд за 30 дней', style: AppTypography.label(color: AppColors.textMuted)),
      const SizedBox(height: 10),
      SizedBox(height: 130, child: _TrendChart(trend: trend)),
    ]));
  }
}

class _IncomeStat extends StatelessWidget {
  const _IncomeStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.label(color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 4),
      FittedBox(child: Text(value, style: AppTypography.price(size: 16, weight: FontWeight.w800, color: color))),
    ]);
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.trend});
  final List trend;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const Center(child: Text('Нет данных'));
    final sig = [for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), _n(trend[i]['signals']).toDouble())];
    final crs = [for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), _n(trend[i]['courses']).toDouble())];
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      minY: 0,
      lineBarsData: [
        LineChartBarData(spots: sig, isCurved: true, curveSmoothness: 0.25, color: AppColors.dxyBlue, barWidth: 2.5, dotData: const FlDotData(show: false)),
        LineChartBarData(spots: crs, isCurved: true, curveSmoothness: 0.25, color: AppColors.goldBright, barWidth: 2.5, dotData: const FlDotData(show: false)),
      ],
    ));
  }
}

// ─────────── Рефералы ───────────
class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.ref});
  final Map ref;
  @override
  Widget build(BuildContext context) {
    final reg = _n(ref['registered']);
    final act = _n(ref['active']);
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('🎁 Рефералы по промокоду', style: AppTypography.h2().copyWith(fontSize: 16)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _IncomeStat(label: 'Зарегистрировались', value: reg.toString(), color: AppColors.textPrimary)),
        Expanded(child: _IncomeStat(label: 'Активные (купили)', value: act.toString(), color: AppColors.profitGreen)),
        Expanded(child: _IncomeStat(label: 'Конверсия', value: reg > 0 ? '${(act / reg * 100).round()}%' : '—', color: AppColors.gold)),
      ]),
    ]));
  }
}

// ─────────── Продажи (сигналы/курсы) ───────────
class _SalesSection extends StatelessWidget {
  const _SalesSection({required this.title, required this.data, required this.labelOf});
  final String title;
  final Map data;
  final String Function(Map) labelOf;

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List?) ?? const [];
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: AppTypography.h2().copyWith(fontSize: 16)),
        Text(_money(_n(data['total_revenue'])), style: AppTypography.price(size: 16, weight: FontWeight.w800, color: AppColors.profitGreen)),
      ]),
      Text('${_n(data['total_buyers'])} покупок', style: AppTypography.label(color: AppColors.textMuted)),
      const SizedBox(height: 8),
      if (items.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Продаж пока нет', style: AppTypography.bodySmall(color: AppColors.textMuted)))
      else
        for (final it in items.take(20))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(children: [
              Expanded(child: Text(labelOf(it as Map), style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('${_n(it['buyers'])} куп.', style: AppTypography.label(color: AppColors.textMuted)),
              const SizedBox(width: 12),
              Text(_money(_n(it['revenue'])), style: AppTypography.price(size: 14, weight: FontWeight.w700, color: AppColors.gold)),
            ]),
          ),
    ]));
  }
}

// ─────────── История выплат ───────────
class _PayoutHistory extends StatelessWidget {
  const _PayoutHistory({required this.payouts});
  final List payouts;

  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('💸 История выплат', style: AppTypography.h2().copyWith(fontSize: 16)),
      const SizedBox(height: 8),
      if (payouts.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Выплат пока не было', style: AppTypography.bodySmall(color: AppColors.textMuted)))
      else
        for (final p in payouts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.profitGreen, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_money(_n(p['amount'])), style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
                Text(_fmtDate(p['created_at']), style: AppTypography.label(color: AppColors.textMuted)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.profitGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('Выплачено', style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
    ]));
  }

  static String _fmtDate(dynamic iso) {
    final d = DateTime.tryParse('${iso ?? ''}');
    if (d == null) return '';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.day)}.${two(l.month)}.${l.year}';
  }
}

// ─────────── shared ───────────
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

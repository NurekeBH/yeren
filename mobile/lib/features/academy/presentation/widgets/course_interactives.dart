import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Кілт бойынша интерактивті виджетті құрастырады.
/// Сабақ мазмұнындағы [InteractiveBlock] осыны шақырады.
Widget buildCourseInteractive(String key) {
  switch (key) {
    case 'emission':
      return const _EmissionSim();
    case 'dxy':
      return const _DxyToggle();
    case 'orderbook':
      return const _OrderBookSim();
    case 'cpi_trainer':
      return const _CpiTrainer();
    case 'nfp_trap':
      return const _NfpTrap();
    case 'fed_panel':
      return const _FedPanel();
    case 'intermarket':
      return const _IntermarketDomino();
    case 'ev_choice':
      return const _EvChoice();
    case 'winrate_rr':
      return const _WinRateRrSim();
    case 'compound':
      return const _CompoundSim();
    default:
      return const SizedBox.shrink();
  }
}

/// Барлық интерактивтерге ортақ контейнер (рамка + тақырып).
class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.child, this.icon = Icons.touch_app});
  final String title;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Көрсеткіш жолағы (мән + түс).
class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value01, required this.color, required this.valueText});
  final String label;
  final double value01;
  final Color color;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            Text(valueText, style: AppTypography.bodySmall(color: color).copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value01.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: AppColors.surfaceMuted,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════ EMISSION ════════════════════════════
class _EmissionSim extends StatefulWidget {
  const _EmissionSim();
  @override
  State<_EmissionSim> createState() => _EmissionSimState();
}

class _EmissionSimState extends State<_EmissionSim> {
  double _printed = 10; // % эмиссии

  @override
  Widget build(BuildContext context) {
    final inflation = _printed * 2; // %
    final breadPrice = 100 * (1 + _printed / 100 * 9); // ₸
    final breads = (1000 / breadPrice);
    final powerRatio = 100 / breadPrice; // покупательная способность

    return _Frame(
      title: 'Симулятор «Эмиссия»',
      icon: Icons.local_atm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Вы — правительство. Печатаете деньги, чтобы покрыть дефицит:',
              style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(
            value: _printed,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_printed.round()}%',
            onChanged: (v) => setState(() => _printed = v),
          ),
          _Bar(label: 'Инфляция', value01: inflation / 200, color: AppColors.lossRed, valueText: '+${inflation.round()}%'),
          const SizedBox(height: 12),
          _Bar(label: 'Покупательная способность', value01: powerRatio, color: AppColors.profitGreen, valueText: '${(powerRatio * 100).round()}%'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              breads >= 9
                  ? '🍞 На 1000 ₸ можно купить ${breads.toStringAsFixed(1)} буханки хлеба.'
                  : breads >= 3
                      ? '🍞 Цены растут! На 1000 ₸ — всего ${breads.toStringAsFixed(1)} буханки.'
                      : '🔥 Гиперинфляция! 1000 ₸ = ${breads.toStringAsFixed(1)} буханки. Деньги превращаются в мусор.',
              style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════ DXY ════════════════════════════
class _DxyToggle extends StatefulWidget {
  const _DxyToggle();
  @override
  State<_DxyToggle> createState() => _DxyToggleState();
}

class _DxyToggleState extends State<_DxyToggle> {
  int _dir = 0; // -1 вниз, 0 нейтр, 1 вверх

  @override
  Widget build(BuildContext context) {
    final goldUp = _dir < 0; // DXY вниз → золото вверх
    return _Frame(
      title: 'Обратная корреляция DXY',
      icon: Icons.sync_alt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Двигайте доллар и смотрите реакцию рынков:',
              style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Btn(
                  label: 'DXY ↑',
                  active: _dir > 0,
                  color: AppColors.dxyBlue,
                  onTap: () => setState(() => _dir = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Btn(
                  label: 'DXY ↓',
                  active: _dir < 0,
                  color: AppColors.dxyBlue,
                  onTap: () => setState(() => _dir = -1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_dir != 0) ...[
            _ReactRow(asset: '🥇 Золото (XAUUSD)', up: goldUp),
            const SizedBox(height: 8),
            _ReactRow(asset: '📈 Акции / риск', up: goldUp),
            const SizedBox(height: 12),
            Text(
              _dir > 0
                  ? 'Доллар крепнет → золото и риск под давлением.'
                  : 'Доллар слабеет → золото и рынки растут.',
              style: AppTypography.bodySmall(color: AppColors.textSecondary),
            ),
          ] else
            Text('Выберите направление DXY ☝️', style: AppTypography.bodySmall(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ReactRow extends StatelessWidget {
  const _ReactRow({required this.asset, required this.up});
  final String asset;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final c = up ? AppColors.profitGreen : AppColors.lossRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(asset, style: AppTypography.bodyMedium()),
          Icon(up ? Icons.trending_up : Icons.trending_down, color: c, size: 22),
        ],
      ),
    );
  }
}

// ════════════════════════════ ORDER BOOK ════════════════════════════
class _OrderBookSim extends StatefulWidget {
  const _OrderBookSim();
  @override
  State<_OrderBookSim> createState() => _OrderBookSimState();
}

class _OrderBookSimState extends State<_OrderBookSim> {
  // Ask-уровни: цена, объём (лотов).
  static const _levels = [
    [2000.0, 5.0],
    [2000.5, 4.0],
    [2001.0, 3.0],
    [2002.0, 6.0],
    [2004.0, 10.0],
  ];
  double? _avg;
  double? _slip;

  void _bigBuy() {
    double remaining = 20; // крупный ордер 20 лотов
    double cost = 0, filled = 0;
    for (final lvl in _levels) {
      if (remaining <= 0) break;
      final take = math.min(remaining, lvl[1]);
      cost += take * lvl[0];
      filled += take;
      remaining -= take;
    }
    setState(() {
      _avg = cost / filled;
      _slip = _avg! - _levels.first[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Стакан заявок (Order Book)',
      icon: Icons.view_list,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final lvl in _levels)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(lvl[0].toStringAsFixed(1),
                        style: AppTypography.price(size: 13, color: AppColors.lossRed)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lvl[1] / 10,
                        minHeight: 14,
                        backgroundColor: AppColors.surfaceMuted,
                        color: AppColors.lossRed.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${lvl[1].round()}', style: AppTypography.label()),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _Btn(label: 'Крупный BUY · 20 лотов', active: true, color: AppColors.profitGreen, onTap: _bigBuy),
          ),
          if (_avg != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Старт: 2000.0 → средняя цена исполнения: ${_avg!.toStringAsFixed(2)}\n'
                'Проскальзывание (slippage): +${_slip!.toStringAsFixed(2)}. Крупный ордер сам двигает цену.',
                style: AppTypography.bodySmall(color: AppColors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════ CPI TRAINER ════════════════════════════
class _CpiTrainer extends StatefulWidget {
  const _CpiTrainer();
  @override
  State<_CpiTrainer> createState() => _CpiTrainerState();
}

class _CpiTrainerState extends State<_CpiTrainer> {
  // Кейстер: фактическое, прогноз, предыдущее.
  static const _cases = [
    [3.7, 3.5, 3.4],
    [3.1, 3.3, 3.4],
    [2.9, 2.9, 3.0],
    [4.2, 3.8, 3.9],
    [3.0, 3.4, 3.6],
  ];
  int _i = 0;
  bool? _correct;

  void _answer(bool sell) {
    final c = _cases[_i];
    final goldDown = c[0] > c[1]; // actual > forecast → золото вниз → правильно SELL
    setState(() => _correct = (sell == goldDown));
  }

  void _next() => setState(() {
        _i = (_i + 1) % _cases.length;
        _correct = null;
      });

  @override
  Widget build(BuildContext context) {
    final c = _cases[_i];
    return _Frame(
      title: 'Тренажёр календаря: CPI',
      icon: Icons.timer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DataChip(label: 'Факт', value: '${c[0]}%', color: AppColors.gold),
              _DataChip(label: 'Прогноз', value: '${c[1]}%', color: AppColors.textSecondary),
              _DataChip(label: 'Пред.', value: '${c[2]}%', color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 14),
          if (_correct == null) ...[
            Text('Куда пойдёт золото? Жмите быстро:',
                style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Btn(label: 'BUY 🥇', active: true, color: AppColors.profitGreen, onTap: () => _answer(false))),
                const SizedBox(width: 10),
                Expanded(child: _Btn(label: 'SELL 🥇', active: true, color: AppColors.lossRed, onTap: () => _answer(true))),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_correct! ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _correct!
                    ? '✅ Верно! Факт ${c[0] > c[1] ? "выше" : "ниже"} прогноза → золото ${c[0] > c[1] ? "падает (SELL)" : "растёт (BUY)"}.'
                    : '❌ Мимо. Факт ${c[0] > c[1] ? "выше" : "ниже"} прогноза → золото ${c[0] > c[1] ? "падает → SELL" : "растёт → BUY"}.',
                style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: _Btn(label: 'Следующая новость →', active: true, color: AppColors.gold, onTap: _next)),
          ],
        ],
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  const _DataChip({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.label(color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.price(size: 18, color: color)),
      ],
    );
  }
}

// ════════════════════════════ NFP TRAP ════════════════════════════
class _NfpTrap extends StatefulWidget {
  const _NfpTrap();
  @override
  State<_NfpTrap> createState() => _NfpTrapState();
}

class _NfpTrapState extends State<_NfpTrap> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Кейс «Двойной капкан»',
      icon: Icons.warning_amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
            child: Text(
              'NFP вышел СИЛЬНЫМ (+280k при прогнозе +180k),\nно безработица тоже ВЫРОСЛА (с 3.8% до 4.1%).\n\nКуда пойдёт цена?',
              style: AppTypography.bodySmall(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          if (!_revealed)
            SizedBox(width: double.infinity, child: _Btn(label: 'Показать разбор', active: true, color: AppColors.gold, onTap: () => setState(() => _revealed = true)))
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Данные противоречат друг другу → сначала «вертолёт» в обе стороны (выбивает стопы). '
                'Решает то, на чём сфокусирована ФРС сейчас. При фокусе на инфляции рынок читает '
                'сильный NFP как повод держать ставку высокой → доллар вверх, золото вниз. '
                'Главный навык — сопоставлять данные, а не реагировать на один заголовок.',
                style: AppTypography.bodySmall(color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════ FED PANEL ════════════════════════════
class _FedPanel extends StatefulWidget {
  const _FedPanel();
  @override
  State<_FedPanel> createState() => _FedPanelState();
}

class _FedPanelState extends State<_FedPanel> {
  double _inflation = 3;
  double _unemployment = 4;

  @override
  Widget build(BuildContext context) {
    final score = _inflation - _unemployment;
    final String stance, rate;
    final bool goldUp;
    if (score > 1.5) {
      stance = '🦅 Ястреб (Hawkish)';
      rate = 'Повышает ставку, QT';
      goldUp = false;
    } else if (score < -1.5) {
      stance = '🕊️ Голубь (Dovish)';
      rate = 'Снижает ставку, QE';
      goldUp = true;
    } else {
      stance = '⚖️ Нейтрально (Hold)';
      rate = 'Ставка без изменений';
      goldUp = score < 0;
    }

    return _Frame(
      title: 'Симуляция: ФРС, инфляция и золото',
      icon: Icons.account_balance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Инфляция: ${_inflation.toStringAsFixed(1)}%', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(value: _inflation, min: 0, max: 10, divisions: 20, onChanged: (v) => setState(() => _inflation = v)),
          Text('Безработица: ${_unemployment.toStringAsFixed(1)}%', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(value: _unemployment, min: 0, max: 10, divisions: 20, onChanged: (v) => setState(() => _unemployment = v)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stance, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Решение ФРС: $rate', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                _ReactRow(asset: '🥇 Золото', up: goldUp),
                const SizedBox(height: 6),
                _ReactRow(asset: '💵 Доллар (DXY)', up: !goldUp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════ INTERMARKET DOMINO ════════════════════════════
class _IntermarketDomino extends StatefulWidget {
  const _IntermarketDomino();
  @override
  State<_IntermarketDomino> createState() => _IntermarketDominoState();
}

class _IntermarketDominoState extends State<_IntermarketDomino> {
  static const _steps = [
    '🛢️ Растёт нефть',
    '🏭 Растёт себестоимость товаров',
    '📈 Растёт инфляция (CPI)',
    '🥇 Трейдеры скупают золото',
  ];
  int _shown = 1;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Межрыночное домино',
      icon: Icons.account_tree,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _steps.length; i++)
            AnimatedOpacity(
              opacity: i < _shown ? 1 : 0.25,
              duration: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < _shown ? AppColors.gold : AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}',
                          style: AppTypography.label(color: i < _shown ? Colors.white : AppColors.textMuted)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_steps[i], style: AppTypography.bodyMedium())),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _Btn(
              label: _shown < _steps.length ? 'Толкнуть домино →' : 'Сбросить ↺',
              active: true,
              color: AppColors.gold,
              onTap: () => setState(() => _shown = _shown < _steps.length ? _shown + 1 : 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════ EV CHOICE ════════════════════════════
class _EvChoice extends StatefulWidget {
  const _EvChoice();
  @override
  State<_EvChoice> createState() => _EvChoiceState();
}

class _EvChoiceState extends State<_EvChoice> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Выбор по мат. ожиданию',
      icon: Icons.calculate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Что выберете?', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          _PickCard(
            title: 'A · Гарантированные \$1,000',
            selected: _picked == 0,
            onTap: () => setState(() => _picked = 0),
          ),
          const SizedBox(height: 8),
          _PickCard(
            title: 'B · 50% шанс выиграть \$3,000',
            selected: _picked == 1,
            onTap: () => setState(() => _picked = 1),
          ),
          if (_picked != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
              child: Text(
                'EV(A) = \$1,000.  EV(B) = 0.5 × \$3,000 = \$1,500.\n'
                '${_picked == 1 ? "✅ Вы выбрали математику. На дистанции B выгоднее." : "🧠 Интуиция выбрала синицу в руках, но математик выбирает B (+\$500 EV)."}',
                style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  const _PickCard({required this.title, required this.selected, required this.onTap});
  final String title;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.1) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Text(title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ════════════════════════════ WIN RATE × RR ════════════════════════════
class _WinRateRrSim extends StatefulWidget {
  const _WinRateRrSim();
  @override
  State<_WinRateRrSim> createState() => _WinRateRrSimState();
}

class _WinRateRrSimState extends State<_WinRateRrSim> {
  double _winRate = 40;
  double _rr = 3;
  List<double>? _curve;
  double? _finalBal;

  void _simulate() {
    final rnd = math.Random();
    double bal = 1000;
    const riskPct = 0.02;
    final curve = <double>[bal];
    for (int i = 0; i < 500; i++) {
      final risk = bal * riskPct;
      if (rnd.nextDouble() < _winRate / 100) {
        bal += risk * _rr;
      } else {
        bal -= risk;
      }
      if (bal < 1) bal = 1;
      curve.add(bal);
    }
    setState(() {
      _curve = curve;
      _finalBal = bal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ev = (_winRate / 100 * _rr) - (1 - _winRate / 100);
    return _Frame(
      title: 'Симулятор: Win Rate × RR',
      icon: Icons.show_chart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Win Rate: ${_winRate.round()}%', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(value: _winRate, min: 10, max: 90, divisions: 16, onChanged: (v) => setState(() => _winRate = v)),
          Text('Risk-to-Reward: 1:${_rr.toStringAsFixed(1)}', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(value: _rr, min: 0.5, max: 5, divisions: 9, onChanged: (v) => setState(() => _rr = v)),
          Row(
            children: [
              Text('EV на сделку: ', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              Text('${ev >= 0 ? "+" : ""}${ev.toStringAsFixed(2)}R',
                  style: AppTypography.bodySmall(color: ev >= 0 ? AppColors.profitGreen : AppColors.lossRed)
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: _Btn(label: 'Симулировать 500 сделок', active: true, color: AppColors.gold, onTap: _simulate)),
          if (_curve != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(painter: _CurvePainter(_curve!)),
            ),
            const SizedBox(height: 8),
            Text(
              'Старт: \$1,000 → итог: \$${_finalBal!.round()}. '
              '${_finalBal! > 1000 ? "Кривая растёт даже при убыточном большинстве сделок." : "Отрицательное EV сливает депозит."}',
              style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter(this.curve);
  final List<double> curve;

  @override
  void paint(Canvas canvas, Size size) {
    if (curve.length < 2) return;
    final maxV = curve.reduce(math.max);
    final minV = curve.reduce(math.min);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final up = curve.last >= curve.first;
    final paint = Paint()
      ..color = up ? AppColors.profitGreen : AppColors.lossRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (int i = 0; i < curve.length; i++) {
      final x = i / (curve.length - 1) * size.width;
      final y = size.height - ((curve[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // Заливка под кривой.
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = (up ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.12),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter old) => old.curve != curve;
}

// ════════════════════════════ COMPOUND ════════════════════════════
class _CompoundSim extends StatefulWidget {
  const _CompoundSim();
  @override
  State<_CompoundSim> createState() => _CompoundSimState();
}

class _CompoundSimState extends State<_CompoundSim> {
  double _rate = 8; // % в месяц
  double _months = 24;

  @override
  Widget build(BuildContext context) {
    final curve = <double>[1000];
    double bal = 1000;
    for (int i = 0; i < _months.round(); i++) {
      bal *= (1 + _rate / 100);
      curve.add(bal);
    }
    return _Frame(
      title: 'Сила сложного процента',
      icon: Icons.trending_up,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Доходность: ${_rate.toStringAsFixed(0)}% в месяц', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(value: _rate, min: 1, max: 20, divisions: 19, onChanged: (v) => setState(() => _rate = v)),
          Text('Срок: ${_months.round()} мес.', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          Slider(value: _months, min: 1, max: 60, divisions: 59, onChanged: (v) => setState(() => _months = v)),
          const SizedBox(height: 6),
          SizedBox(height: 110, width: double.infinity, child: CustomPaint(painter: _CurvePainter(curve))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
            child: Text(
              '\$1,000 → \$${bal.round()} за ${_months.round()} мес.\n'
              'Спокойные проценты на дистанции делают богатым. Жадность ломает кривую.',
              style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════ shared button ════════════════════════════
class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.active, required this.color, required this.onTap});
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: AppTypography.button(color: active ? Colors.white : AppColors.textSecondary)
                .copyWith(fontSize: 14)),
      ),
    );
  }
}

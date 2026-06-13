import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/utils/formatters.dart';
import '../../alerts/presentation/create_alert_sheet.dart';
import '../application/signal_unlock_controller.dart';
import '../data/signals_repository.dart';
import 'unlock_signal_sheet.dart';

class SignalDetailScreen extends ConsumerWidget {
  const SignalDetailScreen({super.key, required this.signalId});

  final String signalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(signalByIdProvider(signalId));

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.common_error}: $e')),
        data: (signal) {
          if (signal == null) return Center(child: Text(l.signals_empty));
          return _Body(signal: signal, l: l);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.signal, required this.l});

  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBuy = signal.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;
    final unlocked = signal.isFree || ref.watch(signalUnlockProvider).contains(signal.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: dirColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                style: AppTypography.button(color: dirColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(signal.pair, style: AppTypography.h1()),
          ],
        ),
        const SizedBox(height: 16),
        _Screenshot(signal: signal, unlocked: unlocked, l: l),
        const SizedBox(height: 16),
        if (unlocked) ...[
          _LevelsCard(signal: signal, l: l),
          const SizedBox(height: 16),
          _AnalysisCard(signal: signal, l: l),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showCreateAlertSheet(
                context,
                ref,
                instrument: signal.pair,
                refPrice: signal.entryMid,
                ideaId: signal.id,
                defaultText: l.alerts_default_idea(signal.pair),
              ),
              icon: const Icon(Icons.notifications_active, size: 18),
              label: Text(l.alerts_notify),
            ),
          ),
        ] else
          _Paywall(signal: signal, l: l),
        const SizedBox(height: 12),
        Text(
          l.idea_disclaimer,
          style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

/// График скриншоты. Ашық болса — нақты сурет (немесе placeholder);
/// ақылы әрі құлыпталған болса — жабық плейсхолдер.
class _Screenshot extends StatelessWidget {
  const _Screenshot({required this.signal, required this.unlocked, required this.l});
  final Signal signal;
  final bool unlocked;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final hasImage = signal.screenshotUrl.isNotEmpty;
    if (unlocked) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: signal.screenshotUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => const _ChartPlaceholder(),
                errorWidget: (_, _, _) => const _ChartPlaceholder(),
              )
            : const _ChartPlaceholder(),
      );
    }
    // Құлыпталған — суретті көрсетпейміз.
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: AppColors.gold, size: 40),
            const SizedBox(height: 8),
            Text(l.signals_screenshot_locked, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.midnight,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.candlestick_chart, color: AppColors.gold, size: 48),
            SizedBox(height: 8),
            Text('Chart screenshot', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

/// Жабық идея — кіру/TP/SL/талдау бұғатталған, ашу батырмасы бар.
class _Paywall extends ConsumerWidget {
  const _Paywall({required this.signal, required this.l});

  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: AppColors.gold, size: 26),
            ),
            const SizedBox(height: 14),
            Text(l.signals_locked_title, style: AppTypography.h2(), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(l.signals_locked_desc,
                style: AppTypography.bodySmall(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            // Жасырылған деңгейлердің тизер-көрінісі
            _LockedRow(label: l.signals_entry_zone),
            const Divider(height: 20),
            _LockedRow(label: '${l.signals_tp1} · ${l.signals_tp2} · ${l.signals_tp3}'),
            const Divider(height: 20),
            _LockedRow(label: l.signals_sl),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${l.signals_tp_pips(signal.tpPips.round())}  ·  ',
                    style: AppTypography.label(color: AppColors.textMuted)),
                Text(l.signals_price_tg(signal.priceTg),
                    style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showUnlockSignalSheet(context, ref, signal),
                icon: const Icon(Icons.lock_open, size: 18),
                label: Text(l.signals_unlock_for(signal.priceTg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
        const Icon(Icons.lock, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('••••', style: AppTypography.price(size: 16, weight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    );
  }
}

class _LevelsCard extends StatelessWidget {
  const _LevelsCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Row(label: l.signals_entry_zone, value: '${Fmt.price(signal.entryFrom)} – ${Fmt.price(signal.entryTo)}'),
            const Divider(height: 24),
            _Row(label: l.signals_tp1, value: Fmt.price(signal.tp1), color: AppColors.profitGreen),
            _Row(label: l.signals_tp2, value: Fmt.price(signal.tp2), color: AppColors.profitGreen),
            _Row(label: l.signals_tp3, value: Fmt.price(signal.tp3), color: AppColors.profitGreen),
            const Divider(height: 24),
            _Row(label: l.signals_sl, value: Fmt.price(signal.sl), color: AppColors.lossRed),
            const Divider(height: 24),
            _Row(label: l.signals_rr, value: '1 : ${signal.rr.toStringAsFixed(2)}'),
            _Row(label: l.signals_confidence, value: '${signal.confidence}%'),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.signals_analysis, style: AppTypography.label(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(signal.analysis, style: AppTypography.bodyMedium()),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
          Text(value, style: AppTypography.price(size: 16, weight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

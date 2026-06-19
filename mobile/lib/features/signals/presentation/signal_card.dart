import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/utils/formatters.dart';
import '../application/signal_unlock_controller.dart';
import 'risk_ui.dart';
import 'unlock_signal_sheet.dart';

class SignalCard extends ConsumerWidget {
  const SignalCard({super.key, required this.signal});

  final Signal signal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isBuy = signal.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;
    final providers = ref.watch(signalProvidersProvider).valueOrNull ?? const [];
    final providerMatches = providers.where((p) => p.id == signal.providerId);
    final provider = providerMatches.isEmpty ? null : providerMatches.first;
    // Paywall тек БЕЛСЕНДІ ақылы идеяларға. Тегін, сатып алынған немесе ЖАБЫЛҒАН
    // (нәтижесі белгілі — track record) идеялар толық көрінеді.
    final isActive = signal.status == SignalStatus.active;
    final purchased = ref.watch(signalUnlockProvider).contains(signal.id);
    // Өзім жариялаған идея да ашық (трейдер өз идеясын құлыпталған көрмеуі тиіс).
    final unlocked = signal.isFree || signal.isMine || !isActive || purchased;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/signals/${signal.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider != null) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => GoRouter.of(context).push('/providers/${provider.id}'),
                    child: Row(
                      children: [
                        Text(provider.avatar, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(provider.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (provider.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 13, color: AppColors.dxyBlue),
                        ],
                        const Spacer(),
                        // Win Rate + рейтинг (кіші шрифт) — трейдер атымен бір жолда.
                        Text('${l.signals_wr_short} ${(provider.winRate * 100).round()}%',
                            style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 11, color: AppColors.gold),
                        const SizedBox(width: 2),
                        Text(provider.rating.toStringAsFixed(1),
                            style: AppTypography.label(color: AppColors.gold).copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else if (signal.isMine && (signal.authorName ?? '').isNotEmpty) ...[
                  // Өзім жариялаған идея — авторды көрсетеміз (provider жазбасы жоқ).
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(signal.authorName!,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 4),
                      Text('· ${l.profile_verified_trader}', style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dirColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                        style: AppTypography.label(color: dirColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(signal.pair, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    // Тегін/ашылған белгісі ғана. Ақылы идея бағасы — тек төмендегі
                    // батырмада (қайталанбайды).
                    if (isActive) ...[
                      if (signal.isFree) ...[
                        _FreeChip(l: l),
                        const SizedBox(width: 6),
                      ] else if (purchased) ...[
                        _UnlockedChip(l: l),
                        const SizedBox(width: 6),
                      ],
                    ],
                    _StatusChip(status: signal.status, l: l),
                  ],
                ),
                const SizedBox(height: 12),
                if (unlocked)
                  // Ашық: сандық деңгейлер болса — тизер; әйтпесе (жылдам идея) мәтін.
                  if (signal.hasLevels)
                    Row(
                      children: [
                        Expanded(child: _MiniStat(label: l.signals_entry_zone, value: '${Fmt.price(signal.entryFrom)}–${Fmt.price(signal.entryTo)}')),
                        Expanded(child: _MiniStat(label: l.signals_rr, value: '1:${signal.rr.toStringAsFixed(1)}')),
                        Expanded(child: _MiniStat(label: l.signals_risk, value: riskShort(signal.risk, l), valueColor: riskColor(signal.risk))),
                      ],
                    )
                  else
                    Text(signal.analysis, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall())
                else
                  // Ақылы әрі құлыпталған — нақты сигнал жасырын.
                  // Тек күтілетін мақсат (пипс) + сатып алу шақыруы (CTA).
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, size: 14, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text(signal.hasLevels ? l.signals_potential : l.signals_paid_idea,
                              style: AppTypography.label(color: AppColors.textSecondary)),
                          const Spacer(),
                          if (signal.hasLevels)
                            Text('≈ ${l.signals_tp_pips(signal.tpPips.round())}',
                                style: AppTypography.price(size: 15, weight: FontWeight.w700, color: AppColors.gold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => showUnlockSignalSheet(context, ref, signal),
                          icon: const Icon(Icons.lock_open, size: 16),
                          label: Text(l.signals_unlock_for(signal.priceTg)),
                        ),
                      ),
                    ],
                  ),
                if (signal.resultPips != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.signals_result_pips(signal.resultPips!),
                    style: AppTypography.price(
                      size: 14,
                      weight: FontWeight.w700,
                      color: signal.resultPips! >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                    ),
                  ),
                ],
                // Дисклеймер әр картадан алынды — тізімде бір рет көрсетіледі (деклаттер).
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.price(size: 13, weight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}

/// Тегін идея — жасыл «Тегін» белгісі.
class _FreeChip extends StatelessWidget {
  const _FreeChip({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.profitGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(l.signals_free_badge,
          style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

/// Ашылған идея — жасыл белгі.
class _UnlockedChip extends StatelessWidget {
  const _UnlockedChip({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.profitGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_open, size: 11, color: AppColors.profitGreen),
          const SizedBox(width: 3),
          Text(l.signals_unlocked_badge, style: AppTypography.label(color: AppColors.profitGreen)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l});
  final SignalStatus status;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    // Белсенді идея «Активные» табында тұр — мәтін артық, тек жасыл нүкте.
    if (status == SignalStatus.active) {
      return Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(color: AppColors.profitGreen, shape: BoxShape.circle),
      );
    }
    final (text, color) = switch (status) {
      SignalStatus.active => (l.signals_status_active, AppColors.profitGreen),
      SignalStatus.closedTp1 => (l.signals_status_tp1, AppColors.profitGreen),
      SignalStatus.closedTp2 => (l.signals_status_tp2, AppColors.profitGreen),
      SignalStatus.closedTp3 => (l.signals_status_tp3, AppColors.profitGreen),
      SignalStatus.closedSl => (l.signals_status_sl, AppColors.lossRed),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTypography.label(color: color)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal_provider.dart';
import '../application/provider_subs_controller.dart';

/// Провайдер картасы — статистика + подписаться батырмасы.
class ProviderCard extends ConsumerWidget {
  const ProviderCard({super.key, required this.provider, this.tappable = true});

  final SignalProvider provider;
  final bool tappable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final subscribed = ref.watch(providerSubsProvider).contains(provider.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: tappable ? () => GoRouter.of(context).push('/providers/${provider.id}') : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.10), shape: BoxShape.circle),
                      child: Text(provider.avatar, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(provider.name, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700))),
                              if (provider.verified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 15, color: AppColors.dxyBlue),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                              const SizedBox(width: 2),
                              Text(provider.rating.toStringAsFixed(1), style: AppTypography.label(color: AppColors.textPrimary)),
                              const SizedBox(width: 8),
                              Icon(Icons.people_outline, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text('${provider.subscribers}', style: AppTypography.label(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Stat(label: l.prov_winrate, value: '${(provider.winRate * 100).toStringAsFixed(0)}%', color: AppColors.profitGreen)),
                    Expanded(child: _Stat(label: l.prov_rr, value: '1:${provider.avgRr.toStringAsFixed(1)}', color: AppColors.purple)),
                    Expanded(child: _Stat(label: l.prov_trades, value: '${provider.tradesCount}', color: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 12),
                // Трейдерді бақылау — ӘРҚАШАН ТЕГІН. Ақылы жазылым тек қолданба деңгейінде (premium).
                SizedBox(
                  width: double.infinity,
                  child: subscribed
                      ? OutlinedButton.icon(
                          onPressed: () => ref.read(providerSubsProvider.notifier).toggle(provider.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(l.prov_following),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            ref.read(providerSubsProvider.notifier).toggle(provider.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.prov_follow_toast)));
                          },
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: Text(l.prov_follow),
                        ),
                ),
                const SizedBox(height: 6),
                // Бақылау = жаңа идея жарияланғанда хабарландыру келеді.
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(l.prov_follow_note,
                          style: AppTypography.label(color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.price(size: 16, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}

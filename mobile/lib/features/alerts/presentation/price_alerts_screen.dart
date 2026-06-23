import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/price_alert.dart';
import '../../home/data/dashboard_repository.dart';
import '../application/price_alert_controller.dart';
import 'create_alert_sheet.dart';

/// Баға ескертулерінің тізімі + қолмен жаңасын қосу.
class PriceAlertsScreen extends ConsumerWidget {
  const PriceAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final alerts = ref.watch(priceAlertControllerProvider);
    // Тірі XAU/USD бағасы — create sheet-те мақсат деңгейінің тірегі әрі тақырып плиткасы.
    final quote = ref.watch(goldQuoteProvider).valueOrNull;
    final refPrice = quote?.price ?? 2374.20;

    return Scaffold(
      appBar: AppBar(title: Text(l.alerts_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateAlertSheet(
          context,
          ref,
          instrument: 'XAU/USD',
          refPrice: refPrice,
          defaultText: l.alerts_default_manual('XAU/USD'),
        ),
        icon: const Icon(Icons.add_alert),
        label: Text(l.alerts_add),
      ),
      body: Column(
        children: [
          if (quote != null) _LivePriceTile(price: quote.price, deltaPct: quote.deltaPct),
          Expanded(
            child: alerts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(l.alerts_empty,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: alerts.length,
                    itemBuilder: (_, i) => _AlertTile(alert: alerts[i], l: l, ref: ref),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Тірі XAU/USD бағасы — тізімнің үстіндегі ықшам плитка.
class _LivePriceTile extends StatelessWidget {
  const _LivePriceTile({required this.price, required this.deltaPct});
  final double price;
  final double deltaPct;

  @override
  Widget build(BuildContext context) {
    final up = deltaPct >= 0;
    final color = up ? AppColors.profitGreen : AppColors.lossRed;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🥇', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text('XAU/USD', style: AppTypography.label(color: AppColors.textSecondary)),
          const Spacer(),
          Text('\$${price.toStringAsFixed(2)}',
              style: AppTypography.price(size: 16, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 18),
          Text('${up ? '+' : ''}${deltaPct.toStringAsFixed(2)}%',
              style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.l, required this.ref});

  final PriceAlert alert;
  final AppLocalizations l;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cond = alert.pips != null
        ? l.alerts_cond_pips(alert.pips!.toStringAsFixed(0), alert.targetPrice.toStringAsFixed(2))
        : l.alerts_cond_price(alert.targetPrice.toStringAsFixed(2));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active, color: AppColors.gold, size: 20),
          ),
          title: Text('${alert.instrument} · $cond',
              style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(alert.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall()),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            onPressed: () {
              final removed = alert;
              ref.read(priceAlertControllerProvider.notifier).remove(alert.id);
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(SnackBar(
                content: Text(l.alerts_deleted),
                action: SnackBarAction(
                  label: l.common_undo,
                  onPressed: () => ref.read(priceAlertControllerProvider.notifier).add(removed),
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}

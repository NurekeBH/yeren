import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/price_alert.dart';
import '../application/price_alert_controller.dart';
import 'create_alert_sheet.dart';

/// Баға ескертулерінің тізімі + қолмен жаңасын қосу.
class PriceAlertsScreen extends ConsumerWidget {
  const PriceAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final alerts = ref.watch(priceAlertControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.alerts_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateAlertSheet(
          context,
          ref,
          instrument: 'XAU/USD',
          refPrice: 2374.20,
          defaultText: l.alerts_default_manual('XAU/USD'),
        ),
        icon: const Icon(Icons.add_alert),
        label: Text(l.alerts_add),
      ),
      body: alerts.isEmpty
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
            onPressed: () => ref.read(priceAlertControllerProvider.notifier).remove(alert.id),
          ),
        ),
      ),
    );
  }
}

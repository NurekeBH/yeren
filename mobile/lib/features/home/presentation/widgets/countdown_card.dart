import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/calendar_event.dart';
import '../../../../shared/utils/formatters.dart';

class CountdownCard extends StatefulWidget {
  const CountdownCard({super.key, required this.event});

  final CalendarEvent event;

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = widget.event;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: AppColors.lossRed, size: 18),
                const SizedBox(width: 8),
                Text(l.home_next_event, style: AppTypography.label(color: AppColors.lossRed)),
                const Spacer(),
                Text(e.currency, style: AppTypography.label(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Text(e.name, style: AppTypography.h2()),
            const SizedBox(height: 4),
            if (e.forecast != null && e.previous != null)
              Text('Forecast ${e.forecast} • Previous ${e.previous}',
                  style: AppTypography.bodySmall()),
            const SizedBox(height: 12),
            Text(
              Fmt.countdown(e.countdown),
              style: AppTypography.price(size: 28, weight: FontWeight.w700, color: AppColors.lossRed),
            ),
            if (e.goldImpactNote != null) ...[
              const SizedBox(height: 8),
              Text(e.goldImpactNote!, style: AppTypography.bodySmall()),
            ],
          ],
        ),
      ),
    );
  }
}

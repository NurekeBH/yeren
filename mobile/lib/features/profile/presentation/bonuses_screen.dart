import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/gen/app_localizations.dart';
import 'promo_section.dart';

/// «Менің бонустарым» толық беті — баланс, қалай табу, промокод, бөлісу,
/// толтыру, тіркелулер саны, код енгізу. Профильден ашылады.
class BonusesScreen extends ConsumerWidget {
  const BonusesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.promo_my_bonuses)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: const [PromoSection()],
      ),
    );
  }
}

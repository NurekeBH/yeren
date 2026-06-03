import 'package:flutter/material.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'user_agreement_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Пайдаланушы келісімінің толық мәтіні. «Қабылдаймын» батырмасы true қайтарады.
class UserAgreementScreen extends ConsumerWidget {
  const UserAgreementScreen({super.key, this.showAccept = true});

  final bool showAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final loc = ref.watch(localeControllerProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l.agreement_title)),
      bottomNavigationBar: showAccept
          ? Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l.agreement_accept),
                ),
              ),
            )
          : null,
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Text(
            userAgreementText(loc),
            style: AppTypography.bodySmall().copyWith(height: 1.55),
          ),
        ),
      ),
    );
  }
}

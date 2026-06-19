import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/profile_controller.dart';

/// «Расталған трейдер болу» өтінімі — командаға (админ/қолдау) ақпарат жіберіледі:
/// трейдинг тәжірибесі (жыл), өзі туралы, дәлел сілтемесі. 3 тегін сигнал — ұсыныс.
Future<void> showTraderApplicationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _TraderApplicationSheet(),
  );
}

class _TraderApplicationSheet extends ConsumerStatefulWidget {
  const _TraderApplicationSheet();

  @override
  ConsumerState<_TraderApplicationSheet> createState() => _State();
}

class _State extends ConsumerState<_TraderApplicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _years = TextEditingController();
  final _about = TextEditingController();
  final _proof = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _years.dispose();
    _about.dispose();
    _proof.dispose();
    super.dispose();
  }

  Future<void> _send(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    if (AppConfig.useRemoteApi) {
      // Remote: өтінім админ модерациясына түседі (бірден трейдер БОЛМАЙДЫ).
      try {
        await ref.read(apiServiceProvider).submitTraderApplication(
              about: _about.text.trim(),
              years: _years.text.trim(),
              proof: _proof.text.trim(),
            );
      } catch (_) {}
    } else {
      // Mock (демо): админ жоқ — бірден трейдер режимін қосамыз.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      ref.read(profileControllerProvider.notifier).toggleVerifiedTrader();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.trader_apply_sent)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(child: Text(l.trader_apply_title, style: AppTypography.h2())),
              ]),
              const SizedBox(height: 6),
              Text(l.trader_apply_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _years,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.trader_apply_years, border: const OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.common_error : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _about,
                maxLines: 3,
                maxLength: 400,
                decoration: InputDecoration(
                  labelText: l.trader_apply_about,
                  hintText: l.trader_apply_about_hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 10) ? l.common_error : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proof,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l.trader_apply_proof,
                  hintText: l.trader_apply_proof_hint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 3 тегін сигнал — сенімге ие болудың ең жақсы жолы.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l.trader_apply_tip,
                          style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.35)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _send(l),
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, size: 18),
                label: Text(l.trader_apply_send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

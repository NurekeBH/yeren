import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/city_field.dart';
import '../../profile/application/profile_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  String _cityValue = ''; // CityField autocomplete мәні
  final _bio = TextEditingController();
  final Set<TradingStyle> _styles = {TradingStyle.smc};
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // Сауда стилі ОПЦИОНАЛ — таңдалмаса да тіркелуді жалғастырамыз.
    ref.read(profileControllerProvider.notifier).completeOnboarding(
          name: _name.text.trim(),
          city: _cityValue.trim(),
          styles: _styles,
          bio: _bio.text.trim(),
        );
    // Явный navigation — router redirect-ке тәуелсіз UX.
    if (mounted) context.go('/home');
  }

  String _styleLabel(TradingStyle s, AppLocalizations l) {
    switch (s) {
      case TradingStyle.smc:
        return l.style_smc;
      case TradingStyle.ict:
        return l.style_ict;
      case TradingStyle.snr:
        return l.style_snr;
      case TradingStyle.trendline:
        return l.style_trendline;
      case TradingStyle.priceAction:
        return l.style_price_action;
      case TradingStyle.breakout:
        return l.style_breakout;
      case TradingStyle.news:
        return l.style_news;
      case TradingStyle.scalping:
        return l.style_scalping;
      case TradingStyle.swing:
        return l.style_swing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.onboarding_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(l.onboarding_name_label, style: AppTypography.label()),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(hintText: l.onboarding_name_hint),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.validation_required : null,
                ),
                const SizedBox(height: 16),
                Text(l.onboarding_city_label, style: AppTypography.label()),
                const SizedBox(height: 6),
                CityField(initial: _cityValue, hint: l.onboarding_city_hint, onChanged: (v) => _cityValue = v),
                const SizedBox(height: 16),
                Text(l.onboarding_style_label, style: AppTypography.label()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in TradingStyle.values)
                      FilterChip(
                        label: Text(_styleLabel(s, l)),
                        selected: _styles.contains(s),
                        onSelected: (v) => setState(() {
                          v ? _styles.add(s) : _styles.remove(s);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l.onboarding_bio_label, style: AppTypography.label()),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bio,
                  maxLength: 200,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _submit, child: Text(l.onboarding_finish)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

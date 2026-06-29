import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../profile/application/profile_controller.dart';
import '../application/auth_controller.dart';
import 'user_agreement_screen.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key, required this.mode, required this.phone, this.country});

  final String mode;
  final String phone;
  final String? country; // тіркеуде таңдалған ел (ISO-2, мыс. KZ)

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _promo = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  bool _obscure = true;
  bool _agreed = false;

  bool get _isRegister => widget.mode == 'register';

  Future<void> _openAgreement() async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const UserAgreementScreen()),
    );
    if (accepted == true && mounted) setState(() => _agreed = true);
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    _promo.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final controller = ref.read(authControllerProvider.notifier);
      if (_isRegister) {
        await controller.register(phone: widget.phone, password: _password.text, country: widget.country);
        // Тіркелу кезінде промокод енгізілсе — бонус есептейміз.
        final code = _promo.text.trim();
        if (code.isNotEmpty) {
          final res = ref.read(profileControllerProvider.notifier).applyPromoCode(code);
          if (mounted && res == PromoResult.applied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).promo_applied(kPromoBonusTg))),
            );
          }
        }
      } else {
        await controller.login(phone: widget.phone, password: _password.text);
      }
      // Явная навигация — redirect-ке тәуелсіз (onboarding-пен бірдей үлгі).
      // Authenticated + !onboarded болса, redirect өзі /auth/onboarding-ке бұрады.
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : AppLocalizations.of(context).common_error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(l.auth_password_title, style: AppTypography.h1()),
                const SizedBox(height: 8),
                Text(l.auth_password_subtitle, style: AppTypography.bodyMedium()),
                const SizedBox(height: 4),
                Text(widget.phone, style: AppTypography.price(size: 14)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: l.auth_password_hint,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) return l.auth_password_too_short;
                    return null;
                  },
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    decoration: InputDecoration(hintText: l.auth_password_confirm_hint),
                    validator: (v) {
                      if (v != _password.text) return l.auth_password_mismatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _promo,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: l.promo_field_hint,
                      prefixIcon: const Icon(Icons.card_giftcard, size: 18),
                      helperText: l.promo_field_help(kPromoBonusTg),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreed,
                        activeColor: AppColors.gold,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                      ),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('${l.agreement_checkbox} ', style: AppTypography.bodySmall()),
                            GestureDetector(
                              onTap: _openAgreement,
                              child: Text(
                                l.agreement_title,
                                style: AppTypography.bodySmall(color: AppColors.gold)
                                    .copyWith(decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: (_busy || (_isRegister && !_agreed)) ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isRegister ? l.auth_register_button : l.auth_login_button),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

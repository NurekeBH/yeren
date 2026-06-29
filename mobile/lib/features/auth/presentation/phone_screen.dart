import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'country_codes.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, required this.mode});

  /// `register` или `login`.
  final String mode;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Country _country = kDefaultCountry;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPicker(context, _country);
    if (picked != null) setState(() => _country = picked);
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    // Толық нөмір: +<елдік код><жергілікті нөмір> (алдыңғы 0 алынады).
    final local = _controller.text.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^0+'), '');
    final phone = '+${_country.dial}$local';
    context.push(
      '/auth/password?mode=${widget.mode}&phone=${Uri.encodeComponent(phone)}&country=${_country.iso}',
    );
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
                Text(l.auth_phone_title, style: AppTypography.h1()),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ел коды таңдау
                    InkWell(
                      onTap: _pickCountry,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_country.flag, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text('+${_country.dial}', style: AppTypography.price(size: 18)),
                            const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        style: AppTypography.price(size: 18),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)]')),
                        ],
                        decoration: InputDecoration(
                          hintText: l.auth_phone_hint,
                          prefixIcon: const Icon(Icons.phone, color: AppColors.textMuted),
                        ),
                        validator: (v) {
                          final raw = (v ?? '').trim();
                          if (raw.isEmpty) return l.validation_required;
                          // Жергілікті нөмір: 7–14 цифр (елдік код бөлек таңдалады).
                          final digits = raw.replaceAll(RegExp(r'\D'), '');
                          if (!RegExp(r'^\d{7,14}$').hasMatch(digits)) return l.auth_phone_error;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(onPressed: _onContinue, child: Text(l.common_continue)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

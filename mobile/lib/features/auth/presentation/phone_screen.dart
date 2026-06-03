import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    final phone = _controller.text.trim();
    context.push('/auth/password?mode=${widget.mode}&phone=${Uri.encodeComponent(phone)}');
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
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  style: AppTypography.price(size: 18),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\+\s\-\(\)]')),
                  ],
                  decoration: InputDecoration(
                    hintText: l.auth_phone_hint,
                    prefixIcon: const Icon(Icons.phone, color: AppColors.textMuted),
                  ),
                  validator: (v) {
                    if (v == null) return l.auth_phone_error;
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return l.auth_phone_error;
                    return null;
                  },
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

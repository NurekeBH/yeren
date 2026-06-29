import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/journal_controller.dart';

/// (id, дисплей атауы) — қолдау көрсетілетін брокерлер.
const _brokers = <(String, String)>[
  ('exness', 'Exness'),
  ('ic_markets', 'IC Markets'),
  ('xm', 'XM'),
  ('pepperstone', 'Pepperstone'),
  ('oanda', 'OANDA'),
  ('fxpro', 'FxPro'),
  ('other', 'Other'),
];

class LinkBrokerScreen extends ConsumerStatefulWidget {
  const LinkBrokerScreen({super.key});
  @override
  ConsumerState<LinkBrokerScreen> createState() => _LinkBrokerScreenState();
}

class _LinkBrokerScreenState extends ConsumerState<LinkBrokerScreen> {
  int _step = 0;
  (String, String)? _broker;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.journal_link_broker)),
      body: Column(
        children: [
          _StepIndicator(current: _step, titles: [l.broker_step_choose_broker, l.broker_step_credentials]),
          const Divider(height: 1),
          Expanded(
            child: switch (_step) {
              0 => _ChooseBroker(onSelect: (b) => setState(() { _broker = b; _step = 1; })),
              _ => _Credentials(broker: _broker!, onBack: () => setState(() => _step = 0), onLinked: () => context.pop()),
            },
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.titles});
  final int current;
  final List<String> titles;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          for (var i = 0; i < titles.length; i++) ...[
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.gold : AppColors.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: i <= current ? AppColors.gold : AppColors.border),
              ),
              child: Text('${i + 1}', style: AppTypography.label(color: i <= current ? Colors.white : AppColors.textMuted)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(titles[i],
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: i == current ? AppColors.gold : AppColors.textMuted)),
            ),
            if (i < titles.length - 1) Container(width: 10, height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _ChooseBroker extends StatelessWidget {
  const _ChooseBroker({required this.onSelect});
  final ValueChanged<(String, String)> onSelect;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        for (final b in _brokers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(b),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(b.$2, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600))),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Credentials extends ConsumerStatefulWidget {
  const _Credentials({required this.broker, required this.onBack, required this.onLinked});
  final (String, String) broker;
  final VoidCallback onBack;
  final VoidCallback onLinked;
  @override
  ConsumerState<_Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends ConsumerState<_Credentials> {
  final _login = TextEditingController();
  final _server = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _platform = 'mt5';
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _server.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(journalControllerProvider).linkAccount({
        'broker': widget.broker.$1,
        'platform': _platform,
        'login': _login.text.trim(),
        'server': _server.text.trim(),
        'investor_password': _password.text,
        'account_name': widget.broker.$2,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.broker.$2} ✓')));
      widget.onLinked();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          Text(widget.broker.$2, style: AppTypography.h2()),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'mt5', label: Text('MetaTrader 5')),
              ButtonSegment(value: 'mt4', label: Text('MetaTrader 4')),
            ],
            selected: {_platform},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _platform = s.first),
          ),
          const SizedBox(height: 16),
          Text(l.broker_account_number, style: AppTypography.label()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _login,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.broker_account_number_hint, border: const OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? l.validation_required : null,
          ),
          const SizedBox(height: 14),
          Text(l.broker_server, style: AppTypography.label()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _server,
            decoration: InputDecoration(hintText: l.broker_server_hint, border: const OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? l.validation_required : null,
          ),
          const SizedBox(height: 14),
          Text(l.broker_investor_password, style: AppTypography.label()),
          const SizedBox(height: 6),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: l.broker_investor_password_hint,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => (v == null || v.length < 4) ? l.auth_password_too_short : null,
          ),
          const SizedBox(height: 12),
          _InfoBanner(text: l.broker_investor_password_help, color: AppColors.gold, icon: Icons.lock_outline),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _busy ? null : () => _submit(l),
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l.broker_link_button),
          ),
          const SizedBox(height: 10),
          TextButton.icon(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back), label: Text(l.common_back)),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text, required this.color, required this.icon});
  final String text;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTypography.bodySmall(color: color))),
        ],
      ),
    );
  }
}

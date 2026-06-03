import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/broker_account.dart';
import '../data/brokers_repository.dart';

class LinkBrokerScreen extends ConsumerStatefulWidget {
  const LinkBrokerScreen({super.key});

  @override
  ConsumerState<LinkBrokerScreen> createState() => _LinkBrokerScreenState();
}

class _LinkBrokerScreenState extends ConsumerState<LinkBrokerScreen> {
  int _step = 0;
  BrokerName? _broker;
  TradingPlatform? _platform;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.journal_link_broker)),
      body: Column(
        children: [
          _StepIndicator(current: _step, titles: [
            l.broker_step_choose_broker,
            l.broker_step_choose_platform,
            l.broker_step_credentials,
          ]),
          const Divider(height: 1),
          Expanded(
            child: switch (_step) {
              0 => _StepChooseBroker(
                  selected: _broker,
                  onSelect: (b) => setState(() {
                    _broker = b;
                    _step = 1;
                  }),
                ),
              1 => _StepChoosePlatform(
                  selected: _platform,
                  onSelect: (p) => setState(() {
                    _platform = p;
                    _step = 2;
                  }),
                  onBack: () => setState(() => _step = 0),
                ),
              _ => _StepCredentials(
                  broker: _broker!,
                  platform: _platform!,
                  onBack: () => setState(() => _step = 1),
                  onLinked: () => context.pop(),
                ),
            },
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Step indicator ────────────────────────────

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
            _Dot(filled: i <= current, label: '${i + 1}'),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                titles[i],
                style: AppTypography.label(
                  color: i == current ? AppColors.gold : AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (i < titles.length - 1)
              Container(width: 10, height: 1, color: AppColors.border),
            if (i < titles.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.label});

  final bool filled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: filled ? AppColors.gold : AppColors.cardSurface,
        shape: BoxShape.circle,
        border: Border.all(color: filled ? AppColors.gold : AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTypography.label(color: filled ? Colors.white : AppColors.textMuted)),
    );
  }
}

// ──────────────────────────── Step 1: broker ────────────────────────────

class _StepChooseBroker extends StatelessWidget {
  const _StepChooseBroker({required this.selected, required this.onSelect});

  final BrokerName? selected;
  final ValueChanged<BrokerName> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        for (final b in BrokerName.values)
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
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(b.displayName, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                      ),
                      if (selected == b) const Icon(Icons.check_circle, color: AppColors.profitGreen),
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

// ──────────────────────────── Step 2: platform ────────────────────────────

class _StepChoosePlatform extends StatelessWidget {
  const _StepChoosePlatform({required this.selected, required this.onSelect, required this.onBack});

  final TradingPlatform? selected;
  final ValueChanged<TradingPlatform> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (TradingPlatform.mt4, l.platform_mt4, l.platform_mt_subtitle, Icons.assessment_outlined),
      (TradingPlatform.mt5, l.platform_mt5, l.platform_mt_subtitle, Icons.bar_chart),
      (TradingPlatform.cTrader, l.platform_ctrader, l.platform_ctrader_subtitle, Icons.bolt),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        for (final (p, title, subtitle, icon) in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(p),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.dxyBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: AppColors.dxyBlue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(subtitle, style: AppTypography.bodySmall()),
                          ],
                        ),
                      ),
                      if (selected == p) const Icon(Icons.check_circle, color: AppColors.profitGreen),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back), label: Text(l.common_back)),
      ],
    );
  }
}

// ──────────────────────────── Step 3: credentials ────────────────────────────

class _StepCredentials extends ConsumerStatefulWidget {
  const _StepCredentials({
    required this.broker,
    required this.platform,
    required this.onBack,
    required this.onLinked,
  });

  final BrokerName broker;
  final TradingPlatform platform;
  final VoidCallback onBack;
  final VoidCallback onLinked;

  @override
  ConsumerState<_StepCredentials> createState() => _StepCredentialsState();
}

class _StepCredentialsState extends ConsumerState<_StepCredentials> {
  final _account = TextEditingController();
  final _server = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _account.dispose();
    _server.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitMt(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(brokersControllerProvider.notifier).linkMt(
            broker: widget.broker,
            platform: widget.platform,
            accountNumber: _account.text,
            server: _server.text,
            investorPassword: _password.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.broker.displayName} ✓')),
        );
        widget.onLinked();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitCTrader(AppLocalizations l) async {
    setState(() => _busy = true);
    try {
      // TZ §9.4: cTrader OAuth flow. Backend дайын болғанда WebView-те ашылады.
      await ref.read(brokersControllerProvider.notifier).linkCTrader(
            broker: widget.broker,
            accountNumber: _account.text.isEmpty ? 'cTrader OAuth' : _account.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.broker.displayName} ✓ OAuth')),
        );
        widget.onLinked();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isCTrader = widget.platform == TradingPlatform.cTrader;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _SummaryHeader(broker: widget.broker, platform: widget.platform),
        const SizedBox(height: 16),
        if (isCTrader)
          _CTraderBlock(onSubmit: () => _submitCTrader(l), busy: _busy)
        else
          _MtForm(
            formKey: _formKey,
            account: _account,
            server: _server,
            password: _password,
            obscure: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            onSubmit: () => _submitMt(l),
            busy: _busy,
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
          label: Text(l.common_back),
        ),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.broker, required this.platform});

  final BrokerName broker;
  final TradingPlatform platform;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(broker.displayName, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(platform.displayName, style: AppTypography.bodySmall()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MtForm extends StatelessWidget {
  const _MtForm({
    required this.formKey,
    required this.account,
    required this.server,
    required this.password,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.busy,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController account;
  final TextEditingController server;
  final TextEditingController password;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.broker_account_number, style: AppTypography.label()),
          const SizedBox(height: 6),
          TextFormField(
            controller: account,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.broker_account_number_hint),
            validator: (v) => (v == null || v.trim().isEmpty) ? l.common_error : null,
          ),
          const SizedBox(height: 16),
          Text(l.broker_server, style: AppTypography.label()),
          const SizedBox(height: 6),
          TextFormField(
            controller: server,
            decoration: InputDecoration(hintText: l.broker_server_hint),
            validator: (v) => (v == null || v.trim().isEmpty) ? l.common_error : null,
          ),
          const SizedBox(height: 16),
          Text(l.broker_investor_password, style: AppTypography.label()),
          const SizedBox(height: 6),
          TextFormField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: l.broker_investor_password_hint,
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) => (v == null || v.length < 4) ? l.auth_password_too_short : null,
          ),
          const SizedBox(height: 12),
          _InfoBanner(text: l.broker_investor_password_help, color: AppColors.gold, icon: Icons.lock_outline),
          const SizedBox(height: 12),
          _InfoBanner(text: l.broker_ea_download_help, color: AppColors.dxyBlue, icon: Icons.download),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('EA download: TODO backend')),
              );
            },
            icon: const Icon(Icons.download),
            label: Text(l.broker_ea_download),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: busy ? null : onSubmit,
            child: busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l.broker_link_button),
          ),
        ],
      ),
    );
  }
}

class _CTraderBlock extends StatelessWidget {
  const _CTraderBlock({required this.onSubmit, required this.busy});

  final VoidCallback onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoBanner(text: l.broker_link_ctrader_help, color: AppColors.dxyBlue, icon: Icons.shield_outlined),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: busy ? null : onSubmit,
          icon: const Icon(Icons.login),
          label: Text(l.broker_link_ctrader),
        ),
      ],
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

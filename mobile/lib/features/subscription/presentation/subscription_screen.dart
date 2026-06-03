import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/subscription.dart';
import '../application/subscription_controller.dart';

/// TZ.rtf override: Kaspi сілтемесі арқылы 30 000 ₸ → чек жүктеу → менеджер растайды.
const _kaspiUrlPlaceholder = 'https://pay.kaspi.kz/pay/traderos-30000';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String? _localReceiptPath;

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _localReceiptPath = file.path);
    }
  }

  Future<void> _openKaspi(AppLocalizations l) async {
    final uri = Uri.parse(_kaspiUrlPlaceholder);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      // Fallback: clipboard-қа көшіру
      await Clipboard.setData(const ClipboardData(text: _kaspiUrlPlaceholder));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaspi: $_kaspiUrlPlaceholder')),
      );
    }
  }

  Future<void> _submit() async {
    if (_localReceiptPath == null) return;
    await ref.read(subscriptionControllerProvider.notifier).submitReceipt(_localReceiptPath!);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sub = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.subscription_get_access)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _StatusBanner(sub: sub, l: l),
          const SizedBox(height: 16),
          if (sub.status == SubscriptionStatus.inactive) ...[
            _StepCard(step: '1', title: l.subscription_step_1, icon: Icons.payment),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openKaspi(l),
              icon: const Icon(Icons.open_in_new),
              label: Text(l.subscription_kaspi_button),
            ),
            const SizedBox(height: 20),
            _StepCard(step: '2', title: l.subscription_step_2, icon: Icons.receipt_long),
            const SizedBox(height: 12),
            _ReceiptPicker(
              localPath: _localReceiptPath,
              onPick: _pickReceipt,
              changeLabel: l.subscription_change_receipt,
              uploadLabel: l.subscription_upload_receipt,
            ),
            const SizedBox(height: 20),
            _StepCard(step: '3', title: l.subscription_step_3, icon: Icons.verified_user),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _localReceiptPath == null ? null : _submit,
              child: Text(l.subscription_confirm_submit),
            ),
          ],
          if (sub.status == SubscriptionStatus.pendingReview) ...[
            if (sub.receiptPath != null) ...[
              Text(l.subscription_receipt_uploaded, style: AppTypography.label(color: AppColors.gold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(sub.receiptPath!), fit: BoxFit.cover, height: 240, width: double.infinity),
              ),
              const SizedBox(height: 24),
            ],
            // Production-да жасырылған. Тек debug build-те қол жетімді —
            // backend жоқ кезде менеджер растайтын жағдайды имитациялауға арналған.
            if (kDebugMode)
              OutlinedButton(
                onPressed: () => ref.read(subscriptionControllerProvider.notifier).mockApprove(),
                child: Text(l.subscription_mock_approve),
              ),
          ],
          if (sub.status == SubscriptionStatus.active) ...[
            Icon(Icons.verified, color: AppColors.profitGreen, size: 64),
            const SizedBox(height: 12),
            Center(
              child: Text(l.subscription_active, style: AppTypography.h1(color: AppColors.profitGreen)),
            ),
            const SizedBox(height: 8),
            if (sub.daysLeft != null)
              Center(child: Text(l.subscription_expires_in(sub.daysLeft!), style: AppTypography.bodyMedium())),
          ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.sub, required this.l});

  final Subscription sub;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (sub.status) {
      SubscriptionStatus.inactive => (l.subscription_inactive, AppColors.lossRed, Icons.lock_outline),
      SubscriptionStatus.pendingReview => (l.subscription_pending, AppColors.gold, Icons.hourglass_top),
      SubscriptionStatus.active => (l.subscription_active, AppColors.profitGreen, Icons.verified),
      SubscriptionStatus.expired => (l.subscription_inactive, AppColors.lossRed, Icons.lock_outline),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium(color: color).copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.title, required this.icon});

  final String step;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(step, style: AppTypography.label(color: AppColors.gold))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTypography.bodyMedium())),
        Icon(icon, color: AppColors.textMuted),
      ],
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({
    required this.localPath,
    required this.onPick,
    required this.changeLabel,
    required this.uploadLabel,
  });

  final String? localPath;
  final VoidCallback onPick;
  final String changeLabel;
  final String uploadLabel;

  @override
  Widget build(BuildContext context) {
    if (localPath == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.upload_file),
        label: Text(uploadLabel),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(localPath!), fit: BoxFit.cover, height: 200),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.refresh),
          label: Text(changeLabel),
        ),
      ],
    );
  }
}

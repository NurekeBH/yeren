import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/utils/formatters.dart';
import '../../alerts/presentation/create_alert_sheet.dart';
import '../application/my_signals_controller.dart';
import '../application/signal_unlock_controller.dart';
import '../application/signal_updates_controller.dart';
import '../application/signal_votes_controller.dart';
import '../data/signals_repository.dart';
import 'unlock_signal_sheet.dart';

class SignalDetailScreen extends ConsumerWidget {
  const SignalDetailScreen({super.key, required this.signalId});

  final String signalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(signalByIdProvider(signalId));

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.common_error}: $e')),
        data: (signal) {
          if (signal == null) return Center(child: Text(l.signals_empty));
          return _Body(signal: signal, l: l);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.signal, required this.l});

  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBuy = signal.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;
    // Paywall тек белсенді ақылы идеяларға; жабылғандар (track record), тегін және
    // өз идеяларым толық ашық.
    final unlocked = signal.isFree ||
        signal.isMine ||
        signal.status != SignalStatus.active ||
        ref.watch(signalUnlockProvider).contains(signal.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: dirColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                style: AppTypography.button(color: dirColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(signal.pair, style: AppTypography.h1()),
          ],
        ),
        const SizedBox(height: 16),
        _Screenshot(signal: signal, unlocked: unlocked, l: l),
        const SizedBox(height: 16),
        if (unlocked) ...[
          // Сандық деңгейлер болса — кесте; жылдам идеяда деңгейлер мәтінде (analysis).
          if (signal.hasLevels) ...[
            _LevelsCard(signal: signal, l: l),
            const SizedBox(height: 16),
          ],
          _AnalysisCard(signal: signal, l: l),
          const SizedBox(height: 16),
          // Трейдердің follow-up апдейттері (timeline) — бәріне көрінеді,
          // авторы (isMine) жаңа апдейт қоса алады.
          _UpdatesCard(signal: signal, l: l),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showCreateAlertSheet(
                context,
                ref,
                instrument: signal.pair,
                refPrice: signal.entryMid,
                ideaId: signal.id,
                defaultText: l.alerts_default_idea(signal.pair),
              ),
              icon: const Icon(Icons.notifications_active, size: 18),
              label: Text(l.alerts_notify),
            ),
          ),
          // Трейдер өз белсенді идеясының нәтижесін қояды (жабады).
          if (signal.isMine && signal.status == SignalStatus.active) ...[
            const SizedBox(height: 16),
            _SetResultCard(signal: signal, l: l),
          ],
          // Жабылған идея: қоғам трейдердің мәлімдеген нәтижесін растайды/даулайды
          // (шынымен TP3-ке жетті ме, әлде SL-ге тиді ме — провайдер шынайылығын тексеру).
          if (!signal.isMine && signal.status != SignalStatus.active) ...[
            const SizedBox(height: 16),
            _VotingCard(signal: signal, l: l),
          ],
        ] else
          _Paywall(signal: signal, l: l),
        const SizedBox(height: 12),
        Text(
          l.idea_disclaimer,
          style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

/// График скриншоты. Ашық болса — нақты сурет (немесе placeholder);
/// ақылы әрі құлыпталған болса — жабық плейсхолдер.
class _Screenshot extends StatelessWidget {
  const _Screenshot({required this.signal, required this.unlocked, required this.l});
  final Signal signal;
  final bool unlocked;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final url = signal.screenshotUrl;
    final hasImage = url.isNotEmpty;
    final isNetwork = url.startsWith('http');
    if (unlocked) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: !hasImage
            ? const _ChartPlaceholder()
            : isNetwork
                ? CachedNetworkImage(
                    imageUrl: url,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const _ChartPlaceholder(),
                    errorWidget: (_, _, _) => const _ChartPlaceholder(),
                  )
                : Image.file(
                    File(url),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ChartPlaceholder(),
                  ),
      );
    }
    // Құлыпталған — суретті көрсетпейміз.
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: AppColors.gold, size: 40),
            const SizedBox(height: 8),
            Text(l.signals_screenshot_locked, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.midnight,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.candlestick_chart, color: AppColors.gold, size: 48),
            SizedBox(height: 8),
            Text('Chart screenshot', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

/// Трейдер өз идеясының нәтижесін қояды: TP1/TP2/TP3 немесе SL → идея жабылады.
class _SetResultCard extends ConsumerWidget {
  const _SetResultCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> set(SignalStatus s) async {
      await ref.read(mySignalsProvider.notifier).setStatus(signal.id, s);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.signals_result_set)));
      }
    }

    Widget btn(String label, SignalStatus s, Color c) => OutlinedButton(
          onPressed: () => set(s),
          style: OutlinedButton.styleFrom(
            foregroundColor: c,
            side: BorderSide(color: c.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(label),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.flag_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(l.signals_set_result, style: AppTypography.h2()),
            ]),
            const SizedBox(height: 4),
            Text(l.signals_set_result_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: btn(l.signals_status_tp1, SignalStatus.closedTp1, AppColors.profitGreen)),
              const SizedBox(width: 8),
              Expanded(child: btn(l.signals_status_tp2, SignalStatus.closedTp2, AppColors.profitGreen)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: btn(l.signals_status_tp3, SignalStatus.closedTp3, AppColors.profitGreen)),
              const SizedBox(width: 8),
              Expanded(child: btn(l.signals_status_sl, SignalStatus.closedSl, AppColors.lossRed)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Ашқан қолданушылар нәтижеге дауыс береді (SL/TP1/TP2/TP3) — қоғам пікірі.
class _VotingCard extends ConsumerWidget {
  const _VotingCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  String _label(String o) => switch (o) {
        'tp1' => l.signals_status_tp1,
        'tp2' => l.signals_status_tp2,
        'tp3' => l.signals_status_tp3,
        _ => l.signals_status_sl,
      };

  /// Трейдер мәлімдеген нәтиже (status → outcome коды).
  String _claimedOutcome() => switch (signal.status) {
        SignalStatus.closedTp1 => 'tp1',
        SignalStatus.closedTp2 => 'tp2',
        SignalStatus.closedTp3 => 'tp3',
        SignalStatus.closedSl => 'sl',
        SignalStatus.active => 'tp1',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vote = ref.watch(signalVotesProvider)[signal.id] ?? ref.read(signalVotesProvider.notifier).of(signal.id);
    final total = vote.total == 0 ? 1 : vote.total;
    final claimed = _claimedOutcome();
    // Қоғам ең көп таңдаған нәтиже.
    String topOutcome = kVoteOutcomes.first;
    for (final o in kVoteOutcomes) {
      if (vote.countOf(o) > vote.countOf(topOutcome)) topOutcome = o;
    }
    final confirmed = topOutcome == claimed;
    final agreePct = ((vote.countOf(claimed) / total) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.fact_check_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(child: Text(l.signals_verify_title, style: AppTypography.h2())),
              Text('${vote.total}', style: AppTypography.label(color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 4),
            // Трейдердің мәлімдемесі + сұрақ.
            Text(l.signals_trader_marked(_label(claimed)),
                style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(l.signals_verify_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            for (final o in kVoteOutcomes) ...[
              _VoteRow(
                label: _label(o) + (o == claimed ? '  ·  ${l.signals_trader_claim}' : ''),
                count: vote.countOf(o),
                pct: vote.countOf(o) / total,
                selected: vote.myVote == o,
                isSl: o == 'sl',
                onTap: () => ref.read(signalVotesProvider.notifier).vote(signal.id, o),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            // Растау вердикті: қоғам трейдердің нәтижесін растай ма?
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: (confirmed ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (confirmed ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(confirmed ? Icons.verified : Icons.warning_amber_rounded,
                      size: 18, color: confirmed ? AppColors.profitGreen : AppColors.lossRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      confirmed ? l.signals_verify_confirmed(agreePct) : l.signals_verify_disputed(_label(topOutcome)),
                      style: AppTypography.bodySmall(color: confirmed ? AppColors.profitGreen : AppColors.lossRed)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteRow extends StatelessWidget {
  const _VoteRow({
    required this.label,
    required this.count,
    required this.pct,
    required this.selected,
    required this.isSl,
    required this.onTap,
  });
  final String label;
  final int count;
  final double pct;
  final bool selected;
  final bool isSl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSl ? AppColors.lossRed : AppColors.profitGreen;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          // Прогресс-фон
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: pct.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: selected ? 0.22 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? color : AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(selected ? Icons.check_circle : Icons.circle_outlined, size: 16, color: selected ? color : AppColors.textMuted),
                const SizedBox(width: 8),
                Text(label, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${(pct * 100).round()}% · $count', style: AppTypography.label(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Трейдердің follow-up апдейттері (timeline). Авторы (isMine) жаңасын қоса алады.
class _UpdatesCard extends ConsumerStatefulWidget {
  const _UpdatesCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  @override
  ConsumerState<_UpdatesCard> createState() => _UpdatesCardState();
}

class _UpdatesCardState extends ConsumerState<_UpdatesCard> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    ref.read(signalUpdatesProvider.notifier).add(widget.signal.id, t, DateTime.now().toIso8601String());
    _text.clear();
    FocusScope.of(context).unfocus();
  }

  String _ago(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final updates = ref.watch(signalUpdatesProvider)[widget.signal.id] ?? const [];
    // Апдейт жоқ әрі автор емес болса — картаны мүлде көрсетпейміз.
    if (updates.isEmpty && !widget.signal.isMine) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.timeline, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(l.signals_updates_title, style: AppTypography.h2()),
            ]),
            const SizedBox(height: 8),
            if (updates.isEmpty)
              Text(l.signals_updates_empty, style: AppTypography.bodySmall(color: AppColors.textSecondary))
            else
              for (final u in updates) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 8),
                      child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                    ),
                    Expanded(child: Text(u.text, style: AppTypography.bodyMedium())),
                    const SizedBox(width: 8),
                    Text(_ago(u.createdAtIso), style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            // Автор жаңа апдейт қосады.
            if (widget.signal.isMine) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l.signals_update_hint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _add,
                    icon: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Жабық идея — кіру/TP/SL/талдау бұғатталған, ашу батырмасы бар.
class _Paywall extends ConsumerWidget {
  const _Paywall({required this.signal, required this.l});

  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: AppColors.gold, size: 26),
            ),
            const SizedBox(height: 14),
            Text(l.signals_locked_title, style: AppTypography.h2(), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(l.signals_locked_desc,
                style: AppTypography.bodySmall(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            // Жасырылған деңгейлердің тизер-көрінісі
            _LockedRow(label: l.signals_entry_zone),
            const Divider(height: 20),
            _LockedRow(label: '${l.signals_tp1} · ${l.signals_tp2} · ${l.signals_tp3}'),
            const Divider(height: 20),
            _LockedRow(label: l.signals_sl),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${l.signals_tp_pips(signal.tpPips.round())}  ·  ',
                    style: AppTypography.label(color: AppColors.textMuted)),
                Text(l.signals_price_tg(signal.priceTg),
                    style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showUnlockSignalSheet(context, ref, signal),
                icon: const Icon(Icons.lock_open, size: 18),
                label: Text(l.signals_unlock_for(signal.priceTg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
        const Icon(Icons.lock, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('••••', style: AppTypography.price(size: 16, weight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    );
  }
}

class _LevelsCard extends StatelessWidget {
  const _LevelsCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Row(label: l.signals_entry_zone, value: '${Fmt.price(signal.entryFrom)} – ${Fmt.price(signal.entryTo)}'),
            const Divider(height: 24),
            _Row(label: l.signals_tp1, value: Fmt.price(signal.tp1), color: AppColors.profitGreen),
            _Row(label: l.signals_tp2, value: Fmt.price(signal.tp2), color: AppColors.profitGreen),
            _Row(label: l.signals_tp3, value: Fmt.price(signal.tp3), color: AppColors.profitGreen),
            const Divider(height: 24),
            _Row(label: l.signals_sl, value: Fmt.price(signal.sl), color: AppColors.lossRed),
            const Divider(height: 24),
            _Row(label: l.signals_rr, value: '1 : ${signal.rr.toStringAsFixed(2)}'),
            _Row(label: l.signals_confidence, value: '${signal.confidence}%'),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.signal, required this.l});
  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.signals_analysis, style: AppTypography.label(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(signal.analysis, style: AppTypography.bodyMedium()),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
          Text(value, style: AppTypography.price(size: 16, weight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_quotes_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../utils/formatters.dart';

/// TZ §5: барлық main экрандарда тұратын тёмная полоса (live баға таспасы).
/// Әр символ — оқылатын «pill»: символ + баға + ▲/▼ пайыз. Сол жақта LIVE пульсі.
class LiveTickerBar extends ConsumerWidget {
  const LiveTickerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveQuotesStreamProvider);
    final cached = ref.watch(cachedQuotesProvider);
    final quotes = async.value ?? cached;

    Color color(String sym) => switch (sym) {
          'XAU/USD' => AppColors.goldBright,
          'DXY' => AppColors.dxyBlue,
          'XAG/USD' => AppColors.silverGray,
          'USOIL' => AppColors.oilRed,
          _ => AppColors.textMuted,
        };

    final isFirstLoad = async.isLoading && cached.isEmpty;
    final hasError = async.hasError && cached.isEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.midnight,
        border: Border(bottom: BorderSide(color: Color(0x33D4A020), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // LIVE индикаторы (тұрақты, скроллданбайды)
          _LiveBadge(error: hasError),
          const SizedBox(width: 10),
          Container(width: 1, height: 22, color: Colors.white.withValues(alpha: 0.10)),
          const SizedBox(width: 10),
          Expanded(
            child: isFirstLoad
                ? Row(
                    children: [
                      const SizedBox(
                        width: 13, height: 13,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.goldBright),
                      ),
                      const SizedBox(width: 10),
                      Text('Загрузка…', style: AppTypography.ticker(color: Colors.white54)),
                    ],
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (final sym in StooqLiveQuotesService.symbols.keys) ...[
                          _TickerPill(
                            symbol: sym,
                            quote: quotes[sym],
                            color: color(sym),
                            prominent: sym == 'XAU/USD',
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Жыпылықтайтын «LIVE» белгісі (немесе офлайн күйі).
class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.error});
  final bool error;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text('OFFLINE', style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: Tween<double>(begin: 0.35, end: 1).animate(_c),
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AppColors.profitGreen, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 5),
        Text('LIVE',
            style: AppTypography.label(color: Colors.white).copyWith(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    );
  }
}

class _TickerPill extends StatelessWidget {
  const _TickerPill({required this.symbol, required this.quote, required this.color, this.prominent = false});

  final String symbol;
  final LiveQuote? quote;
  final Color color;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final q = quote;
    final up = q?.isUp ?? true;
    final deltaColor = up ? AppColors.profitGreen : AppColors.lossRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: prominent ? AppColors.goldBright.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: prominent ? AppColors.goldBright.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(symbol, style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(width: 8),
          if (q == null)
            Text('…', style: AppTypography.ticker(color: Colors.white54))
          else ...[
            Text(
              Fmt.price(q.price),
              style: AppTypography.ticker(color: Colors.white).copyWith(
                fontSize: prominent ? 14 : 13,
                fontWeight: prominent ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: deltaColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 14, color: deltaColor),
                  Text(
                    Fmt.pct(q.deltaPct),
                    style: AppTypography.label(color: deltaColor).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/live_quotes_service.dart';
import '../../../shared/models/kpi.dart';

/// Басты экрандағы XAU/USD «hero» БАСТАПҚЫ fallback-і ғана.
/// Нақты realtime баға (және оның жаңаруы) GoldHeroCard ішіндегі live ағыннан келеді —
/// бұл провайдер бір РЕТ resolve болады. МАҢЫЗДЫ: live провайдерлерді `watch` ЕТПЕЙМІЗ
/// (`ref.read` — бір реттік snapshot), әйтпесе әр тикте қайта resolve болып карта жанып-өшеді.
final goldQuoteProvider = FutureProvider<GoldQuote>((ref) async {
  final quotes = ref.read(cachedQuotesProvider);
  final cached = quotes['XAU/USD'];
  final dxy = quotes['DXY'];
  return GoldQuote(
    price: cached?.price ?? 2374.20,
    deltaAbs: cached?.deltaAbs ?? 0,
    deltaPct: cached?.deltaPct ?? 0,
    sparkline: const [],
    dxy: dxy?.price ?? 0,
    dxyDeltaPct: dxy?.deltaPct ?? 0,
  );
});

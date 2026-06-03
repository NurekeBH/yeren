import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locale/locale_controller.dart';

/// XAU/USD, DXY, XAG/USD, USOIL үшін бірыңғай live quote.
class LiveQuote extends Equatable {
  const LiveQuote({
    required this.symbol,
    required this.price,
    required this.deltaAbs,
    required this.deltaPct,
    required this.timestamp,
  });

  final String symbol;
  final double price;
  final double deltaAbs;
  final double deltaPct;
  final DateTime timestamp;

  bool get isUp => deltaAbs >= 0;

  @override
  List<Object?> get props => [symbol, price, deltaAbs, deltaPct, timestamp];
}

/// Yahoo Finance REST API (key қажет емес, rate limit практикалық тұрғыдан жоқ).
/// Stooq бұрын күндік лимитке жетіп тоқтады — Yahoo Finance тұрақты.
/// XAU/USD: GC=F (Comex Gold futures)
/// DXY:     DX-Y.NYB (USD Index)
/// XAG/USD: SI=F (Silver futures)
/// USOIL:   CL=F (WTI Crude)
class StooqLiveQuotesService {
  StooqLiveQuotesService({Dio? dio, this.pollInterval = const Duration(seconds: 15)})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: const {'User-Agent': 'Mozilla/5.0 (TraderOS)'},
            ));

  final Dio _dio;
  final Duration pollInterval;

  static const _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/';
  static const symbols = <String, String>{
    'XAU/USD': 'GC=F',
    'DXY': 'DX-Y.NYB',
    'XAG/USD': 'SI=F',
    'USOIL': 'CL=F',
  };

  /// Бір тикер бойынша соңғы котировка.
  Future<LiveQuote?> fetchOne(String displaySymbol) async {
    final yahooSym = symbols[displaySymbol];
    if (yahooSym == null) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl$yahooSym',
        queryParameters: const {'interval': '1m', 'range': '1d'},
      );
      final chart = res.data?['chart'] as Map<String, dynamic>?;
      final resultList = chart?['result'] as List?;
      if (resultList == null || resultList.isEmpty) return null;
      final result = resultList.first as Map<String, dynamic>;
      final meta = result['meta'] as Map<String, dynamic>?;
      if (meta == null) return null;
      final price = (meta['regularMarketPrice'] as num?)?.toDouble();
      final prev = (meta['previousClose'] as num?)?.toDouble() ??
          (meta['chartPreviousClose'] as num?)?.toDouble();
      if (price == null || prev == null) return null;
      final delta = price - prev;
      final pct = prev == 0 ? 0.0 : delta / prev * 100;
      return LiveQuote(
        symbol: displaySymbol,
        price: price,
        deltaAbs: delta,
        deltaPct: pct,
        timestamp: DateTime.now(),
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Барлық 4 тикерді параллель сұрау.
  Future<Map<String, LiveQuote>> fetchAll() async {
    final results = await Future.wait(symbols.keys.map(fetchOne));
    final out = <String, LiveQuote>{};
    for (final q in results) {
      if (q != null) out[q.symbol] = q;
    }
    return out;
  }

  /// Periodic polling stream. UI subscribe ете береді — Provider auto-dispose-те cancel.
  Stream<Map<String, LiveQuote>> stream() async* {
    yield await fetchAll();
    while (true) {
      await Future<void>.delayed(pollInterval);
      yield await fetchAll();
    }
  }
}

/// Live ring-buffer (last 20 prices) — sparkline-ды нақты live деректермен толтыру үшін.
class LiveHistory extends StateNotifier<Map<String, List<double>>> {
  LiveHistory() : super(const {});

  static const int maxPoints = 20;

  void push(Map<String, LiveQuote> quotes) {
    final next = Map<String, List<double>>.from(state);
    for (final entry in quotes.entries) {
      final list = List<double>.from(next[entry.key] ?? const []);
      list.add(entry.value.price);
      if (list.length > maxPoints) {
        list.removeRange(0, list.length - maxPoints);
      }
      next[entry.key] = list;
    }
    state = next;
  }
}

final liveHistoryProvider = StateNotifierProvider<LiveHistory, Map<String, List<double>>>(
  (ref) {
    final controller = LiveHistory();
    ref.listen<AsyncValue<Map<String, LiveQuote>>>(liveQuotesStreamProvider, (_, next) {
      next.whenData(controller.push);
    });
    return controller;
  },
);

final liveQuotesServiceProvider = Provider<StooqLiveQuotesService>(
  (ref) => StooqLiveQuotesService(),
);

final liveQuotesStreamProvider = StreamProvider.autoDispose<Map<String, LiveQuote>>(
  (ref) => ref.watch(liveQuotesServiceProvider).stream(),
);

// ─────────────── Cached quotes (last seen) ───────────────

const _cachedQuotesKey = 'live_quotes_cache_v1';

Map<String, LiveQuote> _decodeCached(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final m = (jsonDecode(raw) as Map).cast<String, dynamic>();
    final out = <String, LiveQuote>{};
    m.forEach((key, value) {
      final j = (value as Map).cast<String, dynamic>();
      out[key] = LiveQuote(
        symbol: key,
        price: (j['price'] as num).toDouble(),
        deltaAbs: (j['deltaAbs'] as num).toDouble(),
        deltaPct: (j['deltaPct'] as num).toDouble(),
        timestamp: DateTime.parse(j['timestamp'] as String),
      );
    });
    return out;
  } catch (_) {
    return const {};
  }
}

String _encodeCached(Map<String, LiveQuote> map) {
  final json = <String, Map<String, dynamic>>{};
  map.forEach((k, q) {
    json[k] = {
      'price': q.price,
      'deltaAbs': q.deltaAbs,
      'deltaPct': q.deltaPct,
      'timestamp': q.timestamp.toIso8601String(),
    };
  });
  return jsonEncode(json);
}

/// Соңғы live quotes-ты SharedPreferences-те сақтайды. App restart-та
/// бірден қолжетімді — мок 2374 орнына шынайы соңғы баға көрсетіледі.
class CachedLiveQuotes extends StateNotifier<Map<String, LiveQuote>> {
  CachedLiveQuotes(this._prefs) : super(_decodeCached(_prefs.getString(_cachedQuotesKey)));

  final SharedPreferences _prefs;

  Future<void> push(Map<String, LiveQuote> quotes) async {
    if (quotes.isEmpty) return;
    final merged = {...state, ...quotes};
    state = merged;
    await _prefs.setString(_cachedQuotesKey, _encodeCached(merged));
  }
}

final cachedQuotesProvider =
    StateNotifierProvider<CachedLiveQuotes, Map<String, LiveQuote>>(
  (ref) {
    final controller = CachedLiveQuotes(ref.watch(sharedPreferencesProvider));
    ref.listen<AsyncValue<Map<String, LiveQuote>>>(liveQuotesStreamProvider, (_, next) {
      next.whenData(controller.push);
    });
    return controller;
  },
);

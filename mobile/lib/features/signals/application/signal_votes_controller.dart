import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';

/// Дауыс беруге болатын нәтижелер.
const kVoteOutcomes = ['tp1', 'tp2', 'tp3', 'sl'];

/// Бір сигнал бойынша дауыстар: әр нәтиже саны + пайдаланушының өз дауысы.
class SignalVote {
  const SignalVote({this.counts = const {}, this.myVote});
  final Map<String, int> counts;
  final String? myVote;

  int get total => counts.values.fold(0, (a, b) => a + b);
  int countOf(String o) => counts[o] ?? 0;

  Map<String, dynamic> toJson() => {'c': counts, 'm': myVote};
  factory SignalVote.fromJson(Map<String, dynamic> j) => SignalVote(
        counts: (j['c'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
        myVote: j['m'] as String?,
      );
}

const _votesKey = 'signal_votes_v1';

/// Сигнал нәтижесіне қоғамдық дауыс беру (тек төлеген/ашқан қолданушылар).
/// Mock режимде локал сақталады (детерминалды бастапқы санмен); remote-та backend.
class SignalVotesController extends StateNotifier<Map<String, SignalVote>> {
  SignalVotesController(this._prefs, this._ref) : super(_load(_prefs));

  final SharedPreferences _prefs;
  final Ref _ref;

  static Map<String, SignalVote> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_votesKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, SignalVote.fromJson((v as Map).cast<String, dynamic>())));
  }

  Future<void> _persist() async {
    await _prefs.setString(_votesKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))));
  }

  /// Детерминалды бастапқы сан (қоғам дауысы көрінсін) — id хэшінен.
  static Map<String, int> _seed(String signalId) {
    var h = 0;
    for (final code in signalId.codeUnits) {
      h = (h * 31 + code) & 0x7fffffff;
    }
    return {
      for (var i = 0; i < kVoteOutcomes.length; i++) kVoteOutcomes[i]: 2 + ((h >> (i * 3)) % 7),
    };
  }

  SignalVote of(String signalId) {
    final existing = state[signalId];
    if (existing != null) return existing;
    return SignalVote(counts: _seed(signalId));
  }

  Future<void> vote(String signalId, String outcome) async {
    final cur = of(signalId);
    final counts = Map<String, int>.from(cur.counts);
    // Алдыңғы дауысты алып тастаймыз (бір адам — бір дауыс).
    if (cur.myVote != null && counts.containsKey(cur.myVote)) {
      counts[cur.myVote!] = (counts[cur.myVote!]! - 1).clamp(0, 1 << 30);
    }
    counts[outcome] = (counts[outcome] ?? 0) + 1;
    state = {...state, signalId: SignalVote(counts: counts, myVote: outcome)};
    await _persist();
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(apiServiceProvider).voteSignal(signalId, outcome);
      } catch (_) {/* best-effort */}
    }
  }
}

final signalVotesProvider =
    StateNotifierProvider<SignalVotesController, Map<String, SignalVote>>(
  (ref) => SignalVotesController(ref.watch(sharedPreferencesProvider), ref),
);

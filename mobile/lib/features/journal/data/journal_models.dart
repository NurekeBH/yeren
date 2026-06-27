// Журнал v2 модельдері — backend /journal/* API-ден.
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
double? _dn(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

/// Брокерлік аккаунт (MT4/MT5 investor-password арқылы синхрондалады).
class JournalAccount {
  JournalAccount({
    required this.id,
    required this.broker,
    required this.platform,
    required this.login,
    required this.server,
    required this.accountName,
    required this.currency,
    required this.balance,
    required this.equity,
    required this.syncState,
    required this.syncError,
    required this.lastSyncedAt,
    required this.hasCredentials,
  });

  final String id;
  final String broker;
  final String platform;
  final String login;
  final String server;
  final String? accountName;
  final String currency;
  final double? balance;
  final double? equity;
  final String syncState; // idle|connecting|fetching|upserting|ok|error
  final String? syncError;
  final DateTime? lastSyncedAt;
  final bool hasCredentials;

  factory JournalAccount.fromJson(Map<String, dynamic> j) => JournalAccount(
        id: j['id'].toString(),
        broker: (j['broker'] ?? '').toString(),
        platform: (j['platform'] ?? 'mt5').toString(),
        login: (j['login'] ?? '').toString(),
        server: (j['server'] ?? '').toString(),
        accountName: j['account_name'] as String?,
        currency: (j['currency'] ?? 'USD').toString(),
        balance: _dn(j['balance']),
        equity: _dn(j['equity']),
        syncState: (j['sync_state'] ?? 'idle').toString(),
        syncError: j['sync_error'] as String?,
        lastSyncedAt: DateTime.tryParse('${j['last_synced_at']}'),
        hasCredentials: j['has_credentials'] == true,
      );
}

/// Сделка (брокерден синхрондалған факт + пайдаланушы метадатасы).
class JournalTrade {
  JournalTrade({
    required this.id,
    required this.ticketId,
    required this.symbol,
    required this.side,
    required this.volume,
    required this.openPrice,
    required this.closePrice,
    required this.commission,
    required this.swap,
    required this.profit,
    required this.pips,
    required this.openedAt,
    required this.closedAt,
    required this.source,
    required this.setupTag,
    required this.sessionTag,
    required this.emotion,
    required this.grade,
    required this.notes,
    required this.broker,
  });

  final String id;
  final String ticketId;
  final String symbol;
  final String side; // buy|sell
  final double volume;
  final double openPrice;
  final double? closePrice;
  final double commission;
  final double swap;
  final double profit;
  final double? pips;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String source;
  final String? setupTag;
  final String? sessionTag;
  final String? emotion;
  final String? grade;
  final String? notes;
  final String broker;

  /// Таза P&L: profit + commission + swap.
  double get net => profit + commission + swap;
  bool get isWin => net >= 0;
  bool get isOpen => closedAt == null;

  factory JournalTrade.fromJson(Map<String, dynamic> j) => JournalTrade(
        id: j['id'].toString(),
        ticketId: (j['ticket_id'] ?? '').toString(),
        symbol: (j['symbol'] ?? '').toString(),
        side: (j['side'] ?? 'buy').toString(),
        volume: _d(j['volume']),
        openPrice: _d(j['open_price']),
        closePrice: _dn(j['close_price']),
        commission: _d(j['commission']),
        swap: _d(j['swap']),
        profit: _d(j['profit']),
        pips: _dn(j['pips']),
        openedAt: DateTime.tryParse('${j['opened_at']}') ?? DateTime.now(),
        closedAt: DateTime.tryParse('${j['closed_at']}'),
        source: (j['source'] ?? '').toString(),
        setupTag: j['setup_tag'] as String?,
        sessionTag: j['session_tag'] as String?,
        emotion: j['emotion'] as String?,
        grade: j['grade'] as String?,
        notes: j['notes'] as String?,
        broker: (j['broker'] ?? '').toString(),
      );
}

class CalendarCell {
  CalendarCell(this.day, this.pnl, this.trades);
  final DateTime day;
  final double pnl;
  final int trades;
}

class EmotionStat {
  EmotionStat(this.emotion, this.trades, this.pnl, this.avgPnl, this.winRate);
  final String emotion;
  final int trades;
  final double pnl;
  final double avgPnl;
  final double winRate;
}

class TagStat {
  TagStat(this.key, this.trades, this.pnl, this.winRate);
  final String key;
  final int trades;
  final double pnl;
  final double winRate;
}

/// Журнал аналитикасы: негізгі көрсеткіштер + күнтізбе + эмоциялар + бөліністер.
class JournalAnalytics {
  JournalAnalytics({
    required this.closed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.grossProfit,
    required this.grossLoss,
    required this.netProfit,
    required this.profitFactor,
    required this.avgWin,
    required this.avgLoss,
    required this.expectancy,
    required this.expectancyR,
    required this.best,
    required this.worst,
    required this.calendar,
    required this.emotionCorr,
    required this.emotions,
    required this.setups,
    required this.sessions,
  });

  final int closed;
  final int wins;
  final int losses;
  final double winRate;
  final double grossProfit;
  final double grossLoss;
  final double netProfit;
  final double? profitFactor;
  final double avgWin;
  final double avgLoss;
  final double expectancy;
  final double? expectancyR;
  final double best;
  final double worst;
  final List<CalendarCell> calendar;
  final double? emotionCorr;
  final List<EmotionStat> emotions;
  final List<TagStat> setups;
  final List<TagStat> sessions;

  bool get isEmpty => closed == 0;

  factory JournalAnalytics.fromJson(Map<String, dynamic> j) {
    final s = (j['stats'] as Map?)?.cast<String, dynamic>() ?? const {};
    final cal = (j['calendar'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .map((m) => CalendarCell(DateTime.tryParse('${m['day']}') ?? DateTime.now(), _d(m['pnl']), (m['trades'] as num?)?.toInt() ?? 0))
        .toList();
    final emo = (j['emotions'] as Map?)?.cast<String, dynamic>() ?? const {};
    final emoRows = (emo['rows'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .map((m) => EmotionStat((m['emotion'] ?? '').toString(), (m['trades'] as num?)?.toInt() ?? 0, _d(m['pnl']), _d(m['avg_pnl']), _d(m['win_rate'])))
        .toList();
    List<TagStat> tags(dynamic list) => (list as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .map((m) => TagStat((m['key'] ?? '').toString(), (m['trades'] as num?)?.toInt() ?? 0, _d(m['pnl']), _d(m['win_rate'])))
        .toList();
    return JournalAnalytics(
      closed: (s['closed'] as num?)?.toInt() ?? 0,
      wins: (s['wins'] as num?)?.toInt() ?? 0,
      losses: (s['losses'] as num?)?.toInt() ?? 0,
      winRate: _d(s['win_rate']),
      grossProfit: _d(s['gross_profit']),
      grossLoss: _d(s['gross_loss']),
      netProfit: _d(s['net_profit']),
      profitFactor: _dn(s['profit_factor']),
      avgWin: _d(s['avg_win']),
      avgLoss: _d(s['avg_loss']),
      expectancy: _d(s['expectancy']),
      expectancyR: _dn(s['expectancy_r']),
      best: _d(s['best']),
      worst: _d(s['worst']),
      calendar: cal,
      emotionCorr: _dn(emo['correlation']),
      emotions: emoRows,
      setups: tags(j['setups']),
      sessions: tags(j['sessions']),
    );
  }
}

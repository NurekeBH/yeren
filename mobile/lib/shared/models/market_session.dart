enum MarketSession {
  asia,
  london,
  newYork,
  overlap;

  /// TZ §6.1: ағымдағы сессияны UTC уақыты бойынша анықтау.
  /// Asia: 00–07, London: 07–12, NY Overlap: 12–16, NY: 16–21, ылғи болу үшін else=asia.
  static MarketSession current([DateTime? now]) {
    final hour = (now ?? DateTime.now().toUtc()).hour;
    if (hour >= 7 && hour < 12) return MarketSession.london;
    if (hour >= 12 && hour < 16) return MarketSession.overlap;
    if (hour >= 16 && hour < 21) return MarketSession.newYork;
    return MarketSession.asia;
  }
}

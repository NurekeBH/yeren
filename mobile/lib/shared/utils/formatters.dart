import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../models/market_session.dart';

class Fmt {
  Fmt._();

  static final _price = NumberFormat('#,##0.00', 'en_US');
  static final _priceShort = NumberFormat('#,##0', 'en_US');
  static final _pct = NumberFormat('+#0.00;-#0.00', 'en_US');
  static final _money = NumberFormat('+#,##0.00;-#,##0.00', 'en_US');

  static String price(double v) => _price.format(v);
  static String priceShort(double v) => _priceShort.format(v);
  static String pct(double v) => '${_pct.format(v)}%';
  static String money(double v) => '\$${_money.format(v)}';

  static String pipsSigned(int v) => v >= 0 ? '+$v' : '$v';

  static String relativeTime(DateTime dt, BuildContext context) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String countdown(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String sessionName(MarketSession s, AppLocalizations l) {
    switch (s) {
      case MarketSession.asia:
        return l.home_session_asia;
      case MarketSession.london:
        return l.home_session_london;
      case MarketSession.newYork:
        return l.home_session_ny;
      case MarketSession.overlap:
        return l.home_session_overlap;
    }
  }

  static Color sessionColor(MarketSession s) {
    switch (s) {
      case MarketSession.asia:
        return AppColors.purple;
      case MarketSession.london:
        return AppColors.gold;
      case MarketSession.newYork:
        return AppColors.dxyBlue;
      case MarketSession.overlap:
        return AppColors.goldBright;
    }
  }
}

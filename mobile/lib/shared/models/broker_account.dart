import 'package:equatable/equatable.dart';

/// TZ §9.2: брокерлер тізімі.
enum BrokerName {
  exness,
  icMarkets,
  xm,
  pepperstone,
  oanda,
  fxPro,
  other;

  String get displayName {
    switch (this) {
      case BrokerName.exness:
        return 'Exness';
      case BrokerName.icMarkets:
        return 'IC Markets';
      case BrokerName.xm:
        return 'XM';
      case BrokerName.pepperstone:
        return 'Pepperstone';
      case BrokerName.oanda:
        return 'OANDA';
      case BrokerName.fxPro:
        return 'FxPro';
      case BrokerName.other:
        return 'Other';
    }
  }
}

/// TZ §9.2: платформа таңдау.
enum TradingPlatform {
  mt4,
  mt5,
  cTrader;

  String get displayName {
    switch (this) {
      case TradingPlatform.mt4:
        return 'MetaTrader 4';
      case TradingPlatform.mt5:
        return 'MetaTrader 5';
      case TradingPlatform.cTrader:
        return 'cTrader';
    }
  }

  /// MT4/MT5 — investor password + сервер керек.
  /// cTrader — OAuth, форма жоқ.
  bool get usesOAuth => this == TradingPlatform.cTrader;
}

/// TZ §9.1: байланысқан брокер аккаунты.
/// Investor Password — READ-ONLY (терминалда саудаға рұқсат бермейді).
/// Backend-те AES-256 шифрленеді (TZ §16.3).
class BrokerAccount extends Equatable {
  const BrokerAccount({
    required this.id,
    required this.broker,
    required this.platform,
    required this.accountNumber,
    this.server,
    this.investorPasswordMasked,
    this.balance,
    this.currency = 'USD',
    this.syncedAt,
    this.linkedAt,
    this.isOAuth = false,
  });

  final String id;
  final BrokerName broker;
  final TradingPlatform platform;
  final String accountNumber;

  /// MT4/MT5 ғана. cTrader OAuth-та null.
  final String? server;

  /// UI-да тек masked көрсетіледі (•••• соңғы 2 таңба). Реальді пароль сервер-side ғана.
  final String? investorPasswordMasked;

  final double? balance;
  final String currency;
  final DateTime? syncedAt;
  final DateTime? linkedAt;
  final bool isOAuth;

  String get brokerLabel => broker == BrokerName.other ? 'Other' : broker.displayName;

  @override
  List<Object?> get props => [id, broker, platform, accountNumber, server];
}

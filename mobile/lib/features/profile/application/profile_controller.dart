import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/market_session.dart';
import 'promo_registry.dart';

/// Промокодпен тіркелген жаңа қолданушыға берілетін бонус (₸).
const int kPromoBonusTg = 100;

/// Промокодты қолдану нәтижесі (UI хабарламасын таңдау үшін).
enum PromoResult { applied, alreadyUsed, invalid, ownCode }

/// Сауда стилінің локализацияланған атауы (профиль + өңдеу экрандарында).
String tradingStyleLabel(TradingStyle s, AppLocalizations l) {
  switch (s) {
    case TradingStyle.smc:
      return l.style_smc;
    case TradingStyle.ict:
      return l.style_ict;
    case TradingStyle.snr:
      return l.style_snr;
    case TradingStyle.trendline:
      return l.style_trendline;
    case TradingStyle.priceAction:
      return l.style_price_action;
    case TradingStyle.breakout:
      return l.style_breakout;
    case TradingStyle.news:
      return l.style_news;
    case TradingStyle.scalping:
      return l.style_scalping;
    case TradingStyle.swing:
      return l.style_swing;
  }
}

/// TZ §12 + user 2026-05-26 өзгертуі: pro трейдерлерге арналған толық стиль тізімі.
enum TradingStyle {
  smc,
  ict,
  snr,
  trendline,
  priceAction,
  breakout,
  news,
  scalping,
  swing,
}

/// TZ §12.2: уведомление категориялары.
enum NotificationCategory {
  signals,
  intel,
  calendar,
  academy,
  broker,
}

class NotificationPrefs extends Equatable {
  const NotificationPrefs({this.enabled = const {}, this.dndUntilMorning = true});

  final Map<NotificationCategory, bool> enabled;
  final bool dndUntilMorning;

  bool isOn(NotificationCategory c) => enabled[c] ?? true;

  NotificationPrefs toggle(NotificationCategory c) {
    final next = Map<NotificationCategory, bool>.from(enabled);
    next[c] = !isOn(c);
    return NotificationPrefs(enabled: next, dndUntilMorning: dndUntilMorning);
  }

  NotificationPrefs toggleDnd() =>
      NotificationPrefs(enabled: enabled, dndUntilMorning: !dndUntilMorning);

  Map<String, dynamic> toJson() => {
        'enabled': enabled.map((k, v) => MapEntry(k.name, v)),
        'dnd': dndUntilMorning,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationPrefs();
    final raw = (json['enabled'] as Map?)?.cast<String, dynamic>() ?? {};
    final map = <NotificationCategory, bool>{};
    for (final c in NotificationCategory.values) {
      if (raw.containsKey(c.name)) map[c] = raw[c.name] as bool;
    }
    return NotificationPrefs(
      enabled: map,
      dndUntilMorning: (json['dnd'] as bool?) ?? true,
    );
  }

  @override
  List<Object?> get props => [enabled, dndUntilMorning];
}

class UserProfile extends Equatable {
  const UserProfile({
    this.name = '',
    this.city = '',
    this.styles = const {},
    this.bio = '',
    this.avatarPath,
    this.preferredSessions = const {},
    this.notifications = const NotificationPrefs(),
    this.gallup,
    this.xp = 0,
    this.streak = 0,
    this.weekProgress = const [false, false, false, false, false, false, false],
    this.onboardedFlag = false,
    this.isVerifiedTrader = false,
    this.promoCode = '',
    this.bonusBalance = 0,
    this.referredBy,
    this.referralCount = 0,
  });

  final String name;
  final String city;
  final Set<TradingStyle> styles;
  final String bio;
  final String? avatarPath;
  final Set<MarketSession> preferredSessions;
  final NotificationPrefs notifications;
  final GallupResult? gallup;
  final int xp;
  final int streak;
  final List<bool> weekProgress;

  /// Трейдердің жеке промокоды (расталған трейдерде болады). Бөлісу үшін.
  final String promoCode;

  /// Бонус балансы (₸) — промокодпен тіркелгенде +100; идея ашқанда жұмсалады.
  final int bonusBalance;

  /// Тіркелу кезінде енгізілген промокод (бір рет қана бонус алу үшін белгі).
  final String? referredBy;

  /// Осы трейдердің промокодымен тіркелген қолданушылар саны (remote-та нақты).
  final int referralCount;

  /// Қайта оралған пайдаланушы (login) немесе онбордингті аяқтаған соң — true.
  /// Профиль сұрақнамасын қайталап сұрамас үшін.
  final bool onboardedFlag;

  /// Расталған трейдер режимі — идея жариялау/басқару мүмкіндігін ашады.
  final bool isVerifiedTrader;

  bool get isOnboarded => onboardedFlag || (name.isNotEmpty && styles.isNotEmpty);

  UserProfile copyWith({
    String? name,
    String? city,
    Set<TradingStyle>? styles,
    String? bio,
    String? avatarPath,
    Set<MarketSession>? preferredSessions,
    NotificationPrefs? notifications,
    GallupResult? gallup,
    int? xp,
    int? streak,
    List<bool>? weekProgress,
    bool? onboardedFlag,
    bool? isVerifiedTrader,
    String? promoCode,
    int? bonusBalance,
    String? referredBy,
    int? referralCount,
  }) =>
      UserProfile(
        name: name ?? this.name,
        city: city ?? this.city,
        styles: styles ?? this.styles,
        bio: bio ?? this.bio,
        avatarPath: avatarPath ?? this.avatarPath,
        preferredSessions: preferredSessions ?? this.preferredSessions,
        notifications: notifications ?? this.notifications,
        gallup: gallup ?? this.gallup,
        xp: xp ?? this.xp,
        streak: streak ?? this.streak,
        weekProgress: weekProgress ?? this.weekProgress,
        onboardedFlag: onboardedFlag ?? this.onboardedFlag,
        isVerifiedTrader: isVerifiedTrader ?? this.isVerifiedTrader,
        promoCode: promoCode ?? this.promoCode,
        bonusBalance: bonusBalance ?? this.bonusBalance,
        referredBy: referredBy ?? this.referredBy,
        referralCount: referralCount ?? this.referralCount,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'styles': styles.map((s) => s.name).toList(),
        'bio': bio,
        'avatarPath': avatarPath,
        'preferredSessions': preferredSessions.map((s) => s.name).toList(),
        'notifications': notifications.toJson(),
        'gallupDominant': gallup?.dominant.name,
        'gallupScores': gallup?.scores.map((k, v) => MapEntry(k.name, v)),
        'xp': xp,
        'streak': streak,
        'weekProgress': weekProgress,
        'onboarded': onboardedFlag,
        'isVerifiedTrader': isVerifiedTrader,
        'promoCode': promoCode,
        'bonusBalance': bonusBalance,
        'referredBy': referredBy,
        'referralCount': referralCount,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Set<T> enumSet<T extends Enum>(List<T> values, dynamic raw) {
      final list = (raw as List?)?.cast<String>() ?? const <String>[];
      return list
          .map((s) => values.where((v) => v.name == s))
          .expand((e) => e)
          .toSet();
    }

    GallupResult? gallup;
    final dom = json['gallupDominant'] as String?;
    final scoresRaw = (json['gallupScores'] as Map?)?.cast<String, dynamic>();
    if (dom != null && scoresRaw != null) {
      final scores = <GallupProfile, int>{};
      for (final p in GallupProfile.values) {
        scores[p] = (scoresRaw[p.name] as num?)?.toInt() ?? 0;
      }
      final dominant = GallupProfile.values.firstWhere((p) => p.name == dom, orElse: () => GallupProfile.disciplined);
      gallup = GallupResult(dominant: dominant, scores: scores);
    }

    return UserProfile(
      name: (json['name'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      styles: enumSet<TradingStyle>(TradingStyle.values, json['styles']),
      bio: (json['bio'] as String?) ?? '',
      avatarPath: json['avatarPath'] as String?,
      preferredSessions: enumSet<MarketSession>(MarketSession.values, json['preferredSessions']),
      notifications: NotificationPrefs.fromJson((json['notifications'] as Map?)?.cast<String, dynamic>()),
      gallup: gallup,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      weekProgress: ((json['weekProgress'] as List?)?.cast<bool>()) ??
          const [false, false, false, false, false, false, false],
      onboardedFlag: (json['onboarded'] as bool?) ?? false,
      isVerifiedTrader: (json['isVerifiedTrader'] as bool?) ?? false,
      promoCode: (json['promoCode'] as String?) ?? '',
      bonusBalance: (json['bonusBalance'] as num?)?.toInt() ?? 0,
      referredBy: json['referredBy'] as String?,
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, city, styles, bio, avatarPath, preferredSessions, notifications, gallup, xp, streak, weekProgress, onboardedFlag, isVerifiedTrader, promoCode, bonusBalance, referredBy, referralCount];
}

const _profileKey = 'user_profile_v1';

class ProfileController extends StateNotifier<UserProfile> {
  ProfileController(this._ref) : super(_loadInitial(_ref.read(sharedPreferencesProvider)));

  final Ref _ref;
  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  /// Remote режимде профильді backend-ке (PATCH /auth/me) синхрондау.
  void _syncRemote() {
    if (!AppConfig.useRemoteApi) return;
    _ref.read(apiServiceProvider).updateMe({
      'name': state.name,
      'city': state.city,
      'bio': state.bio,
      'trading_styles': state.styles.map((s) => s.name).toList(),
      if (state.promoCode.isNotEmpty) 'promo_code': state.promoCode,
      'is_verified_trader': state.isVerifiedTrader,
    }).catchError((_) {});
  }

  static UserProfile _loadInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return const UserProfile(
        streak: 5,
        weekProgress: [true, true, true, true, true, false, false],
      );
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_profileKey, jsonEncode(state.toJson()));
  }

  void _set(UserProfile next) {
    state = next;
    _persist();
  }

  void completeOnboarding({
    required String name,
    required String city,
    required Set<TradingStyle> styles,
    String bio = '',
    String? promoCode,
  }) {
    _set(state.copyWith(name: name, city: city, styles: styles, bio: bio, onboardedFlag: true));
    // Тіркелу кезінде промокод енгізілсе — бонус есептейміз.
    final code = promoCode?.trim() ?? '';
    if (code.isNotEmpty) applyPromoCode(code);
    _syncRemote();
  }

  /// Трейдер промокодын генерациялау (бір рет, тұрақты түрде сақталады).
  static String _genPromoCode(String name) {
    final letters = name.toUpperCase().replaceAll(RegExp(r'[^A-ZА-ЯЁ]'), '');
    final prefix = letters.isEmpty ? 'ALTYN' : letters.substring(0, letters.length.clamp(0, 5));
    final seed = (name.isEmpty ? DateTime.now().millisecondsSinceEpoch : name.hashCode).abs();
    final num = 1000 + seed % 9000;
    return '$prefix$num';
  }

  /// Промокодты қолдану. Тіркелуде немесе профильден кейін шақырылады.
  /// Сәтті болса бонус балансқа [kPromoBonusTg] қосылады.
  PromoResult applyPromoCode(String raw) {
    final code = raw.trim().toUpperCase();
    if (state.referredBy != null && state.referredBy!.isNotEmpty) {
      return PromoResult.alreadyUsed;
    }
    if (code.length < 4 || code.length > 24 || !RegExp(r'^[A-ZА-ЯЁ0-9-]+$').hasMatch(code)) {
      return PromoResult.invalid;
    }
    if (state.promoCode.isNotEmpty && code == state.promoCode.toUpperCase()) {
      return PromoResult.ownCode;
    }
    _set(state.copyWith(
      referredBy: code,
      bonusBalance: state.bonusBalance + kPromoBonusTg,
    ));
    // Құрылғы-жергілікті есеп: осы кодпен тіркелуді +1 (трейдер санды көреді).
    _ref.read(promoRegistryProvider.notifier).record(code);
    // Remote режимде backend-ке тіркейміз (бонусты сервер де есептейді).
    if (AppConfig.useRemoteApi) {
      _ref.read(apiServiceProvider).redeemPromo(code).catchError((_) {});
    }
    return PromoResult.applied;
  }

  /// Бонусты жұмсау (идея ашқанда). Баланстан [amount] шегереміз.
  void spendBonus(int amount) {
    if (amount <= 0) return;
    _set(state.copyWith(bonusBalance: (state.bonusBalance - amount).clamp(0, 1 << 31)));
  }

  /// Login (mock): қайта оралған пайдаланушы — профиль сұрақнамасын өткізіп жібереміз.
  void markReturningUser() {
    if (state.isOnboarded) return;
    _set(state.copyWith(onboardedFlag: true));
  }

  /// Login (remote): backend профилін (/auth/me) жергілікті профильге толтырамыз.
  /// Бар деректер онбордингті өткізіп жіберуге жеткілікті болады.
  Future<void> hydrateFromRemote() async {
    if (!AppConfig.useRemoteApi) return;
    try {
      final me = await _ref.read(apiServiceProvider).me();
      final user = (me['user'] as Map?)?.cast<String, dynamic>() ?? me;
      final stylesRaw = (user['trading_styles'] as List?)?.cast<dynamic>() ?? const [];
      final styles = stylesRaw
          .map((s) => TradingStyle.values.where((v) => v.name == s.toString()))
          .expand((e) => e)
          .toSet();
      _set(state.copyWith(
        name: (user['name'] as String?)?.trim().isNotEmpty == true ? user['name'] as String : state.name,
        city: (user['city'] as String?) ?? state.city,
        bio: (user['bio'] as String?) ?? state.bio,
        styles: styles.isNotEmpty ? styles : state.styles,
        onboardedFlag: true,
        isVerifiedTrader: (user['is_verified_trader'] as bool?) ?? state.isVerifiedTrader,
        promoCode: (user['promo_code'] as String?) ?? state.promoCode,
        bonusBalance: (user['bonus_balance'] as num?)?.toInt() ?? state.bonusBalance,
        referredBy: (user['referred_by'] as String?) ?? state.referredBy,
        referralCount: (user['referral_count'] as num?)?.toInt() ?? state.referralCount,
      ));
    } catch (_) {
      // Backend қолжетімсіз — қайта оралған пайдаланушы деп белгілейміз.
      markReturningUser();
    }
  }

  /// Профильді өңдеу (аты, қаласы, bio, сауда стильдері).
  void updateProfile({
    required String name,
    required String city,
    required String bio,
    required Set<TradingStyle> styles,
  }) {
    _set(state.copyWith(name: name, city: city, bio: bio, styles: styles));
    _syncRemote();
  }

  void toggleVerifiedTrader() {
    final next = !state.isVerifiedTrader;
    // Трейдер болғанда жеке промокод беріледі (бұрын жоқ болса).
    final code = next && state.promoCode.isEmpty ? _genPromoCode(state.name) : state.promoCode;
    _set(state.copyWith(isVerifiedTrader: next, promoCode: code));
    _syncRemote();
  }

  void setAvatar(String path) => _set(state.copyWith(avatarPath: path));
  void setBio(String value) => _set(state.copyWith(bio: value));

  void togglePreferredSession(MarketSession s) {
    final next = Set<MarketSession>.from(state.preferredSessions);
    next.contains(s) ? next.remove(s) : next.add(s);
    _set(state.copyWith(preferredSessions: next));
  }

  void toggleStyle(TradingStyle s) {
    final next = Set<TradingStyle>.from(state.styles);
    next.contains(s) ? next.remove(s) : next.add(s);
    _set(state.copyWith(styles: next));
  }

  void toggleNotification(NotificationCategory c) =>
      _set(state.copyWith(notifications: state.notifications.toggle(c)));

  void toggleDnd() =>
      _set(state.copyWith(notifications: state.notifications.toggleDnd()));

  void setGallup(GallupResult result) => _set(state.copyWith(gallup: result));

  void addXp(int amount) => _set(state.copyWith(xp: state.xp + amount));

  void markTodayCompleted() {
    final today = DateTime.now().weekday - 1;
    final next = List<bool>.from(state.weekProgress);
    if (today >= 0 && today < next.length) {
      final wasCompleted = next[today];
      next[today] = true;
      _set(state.copyWith(
        weekProgress: next,
        streak: wasCompleted ? state.streak : state.streak + 1,
      ));
    }
  }

  void reset() {
    _prefs.remove(_profileKey);
    state = const UserProfile(
      streak: 5,
      weekProgress: [true, true, true, true, true, false, false],
    );
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, UserProfile>(
  (ref) => ProfileController(ref),
);

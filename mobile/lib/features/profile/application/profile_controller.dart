import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/market_session.dart';

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
  ideas,
  review,
  academy,
  broker,
  streak,
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

  bool get isOnboarded => name.isNotEmpty && styles.isNotEmpty;

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
    );
  }

  @override
  List<Object?> get props => [name, city, styles, bio, avatarPath, preferredSessions, notifications, gallup, xp, streak, weekProgress];
}

const _profileKey = 'user_profile_v1';

class ProfileController extends StateNotifier<UserProfile> {
  ProfileController(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

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
    required Set<MarketSession> preferredSessions,
    String bio = '',
  }) {
    _set(state.copyWith(
      name: name,
      city: city,
      styles: styles,
      bio: bio,
      preferredSessions: preferredSessions,
    ));
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
  (ref) => ProfileController(ref.watch(sharedPreferencesProvider)),
);

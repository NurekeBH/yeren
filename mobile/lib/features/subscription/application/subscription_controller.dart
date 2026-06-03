import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/subscription.dart';

const _subKey = 'subscription_v1';

class SubscriptionController extends StateNotifier<Subscription> {
  SubscriptionController(this._prefs) : super(_loadInitial(_prefs));

  final SharedPreferences _prefs;

  static Subscription _loadInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_subKey);
    if (raw == null || raw.isEmpty) {
      return const Subscription(status: SubscriptionStatus.inactive);
    }
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return Subscription(
        status: SubscriptionStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => SubscriptionStatus.inactive,
        ),
        activatedAt: j['activatedAt'] == null ? null : DateTime.parse(j['activatedAt'] as String),
        expiresAt: j['expiresAt'] == null ? null : DateTime.parse(j['expiresAt'] as String),
        receiptPath: j['receiptPath'] as String?,
      );
    } catch (_) {
      return const Subscription(status: SubscriptionStatus.inactive);
    }
  }

  Future<void> _persist() async {
    final j = {
      'status': state.status.name,
      'activatedAt': state.activatedAt?.toIso8601String(),
      'expiresAt': state.expiresAt?.toIso8601String(),
      'receiptPath': state.receiptPath,
    };
    await _prefs.setString(_subKey, jsonEncode(j));
  }

  void _set(Subscription next) {
    state = next;
    _persist();
  }

  /// Чекті жүктеу — менеджер растағанша pendingReview статусы.
  Future<void> submitReceipt(String localPath) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _set(state.copyWith(
      status: SubscriptionStatus.pendingReview,
      receiptPath: localPath,
    ));
  }

  /// MOCK: менеджер растауын имитациялау (kDebugMode-та ғана UI-да көрінеді).
  Future<void> mockApprove() async {
    final now = DateTime.now();
    _set(state.copyWith(
      status: SubscriptionStatus.active,
      activatedAt: now,
      expiresAt: now.add(const Duration(days: 30)),
    ));
  }

  void reset() {
    _prefs.remove(_subKey);
    state = const Subscription(status: SubscriptionStatus.inactive);
  }
}

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, Subscription>(
  (ref) => SubscriptionController(ref.watch(sharedPreferencesProvider)),
);

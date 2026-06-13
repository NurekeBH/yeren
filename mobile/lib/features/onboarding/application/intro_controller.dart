import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';

const _introSeenKey = 'intro_seen_v1';

/// Бірінші іске қосуда көрсетілетін таныстыру слайдтары көрілді ме.
/// false → intro карусель көрсетіледі; complete() шақырылғанда true болады.
class IntroController extends StateNotifier<bool> {
  IntroController(this._ref) : super(_load(_ref));

  final Ref _ref;

  static bool _load(Ref ref) =>
      ref.read(sharedPreferencesProvider).getBool(_introSeenKey) ?? false;

  Future<void> complete() async {
    state = true;
    await _ref.read(sharedPreferencesProvider).setBool(_introSeenKey, true);
  }
}

final introControllerProvider = StateNotifierProvider<IntroController, bool>(
  (ref) => IntroController(ref),
);

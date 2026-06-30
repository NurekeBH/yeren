import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1 секундта бір "тіктейтін" provider — countdown / live timer виджеттерге.
/// Watch ету: `ref.watch(secondTickerProvider)` → widget кесте сайын rebuild.
/// ПЕРФОРМАНС: autoDispose — ешкім қарамаса (календарь/басты бет жабық),
/// таймер тоқтайды (фонда секунд-сайын rebuild болмайды, батарея/CPU үнемдейді).
final secondTickerProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    controller.add(DateTime.now());
  });
  controller.add(DateTime.now());
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/signal.dart';
import '../data/signals_repository.dart';

/// Провайдер идея жариялау / нәтиже қою әрекеттері.
/// Backend — жалғыз дереккөз: тізім GET /signals-тен оқылады, ал автор өз идеясын
/// `is_mine` арқылы ашық көреді. Сондықтан жергілікті кэш САҚТАЛМАЙДЫ — әйтпесе
/// дәл сол идея екі рет (жергілікті + backend) көрінер еді.
class MySignalsController {
  MySignalsController(this._ref);

  final Ref _ref;

  /// XAU/USD: нәтижені пипспен есептеу (TP → +, SL → −).
  static int _pipsFor(Signal s, SignalStatus status) {
    final target = switch (status) {
      SignalStatus.closedTp1 => s.tp1,
      SignalStatus.closedTp2 => s.tp2,
      SignalStatus.closedTp3 => s.tp3,
      SignalStatus.closedSl => s.sl,
      SignalStatus.active => s.entryMid,
    };
    final dist = ((target - s.entryMid).abs() / Signal.pipSize).round();
    return status == SignalStatus.closedSl ? -dist : dist;
  }

  /// Жаңа идея жариялау → backend-ке POST → тізімді жаңарту.
  Future<void> publish(Signal signal) async {
    if (AppConfig.useRemoteApi) {
      await _ref.read(apiServiceProvider).publishSignal(_toApi(signal));
    }
    _ref.invalidate(signalsListProvider);
  }

  /// Өз идеясының нәтижесін қою (TP1/TP2/TP3/SL) → backend-ке жабу → тізімді жаңарту.
  Future<void> setStatus(Signal signal, SignalStatus status) async {
    if (AppConfig.useRemoteApi && status != SignalStatus.active) {
      await _ref
          .read(apiServiceProvider)
          .closeSignal(signal.id, status.name, _pipsFor(signal, status));
    }
    _ref.invalidate(signalsListProvider);
    _ref.invalidate(signalByIdProvider(signal.id));
  }

  Map<String, dynamic> _toApi(Signal s) => {
        'pair': s.pair,
        'direction': s.direction.name,
        'entry_from': s.entryFrom,
        'entry_to': s.entryTo,
        'tp1': s.tp1,
        'tp2': s.tp2 == 0 ? null : s.tp2,
        'tp3': s.tp3 == 0 ? null : s.tp3,
        'sl': s.sl,
        'rr': s.rr,
        'confidence': s.confidence,
        'analysis': s.analysis,
        'is_free': s.isFree,
      };
}

final mySignalsProvider = Provider<MySignalsController>((ref) => MySignalsController(ref));

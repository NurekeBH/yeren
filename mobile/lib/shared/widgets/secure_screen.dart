import 'package:flutter/widgets.dart';
import 'package:screen_protector/screen_protector.dart';

/// Құпия контентті (идея деңгейлері, ақылы курс) скриншот/экран жазудан қорғайтын орауыш.
/// Экран ашық тұрғанда қорғау қосылады, жабылғанда өшеді.
/// Android: FLAG_SECURE (скриншот бұғатталады, экран жазуда қара экран).
/// iOS: скриншот қорғау (preventScreenshotOn).
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});
  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn().catchError((_) {});
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff().catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

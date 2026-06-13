import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Брендтелген splash экраны — логотип + ALTYN сөзбелгісі + tagline.
/// Қысқа анимациядан кейін негізгі ағынға өтеді (intro/home — redirect шешеді).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  late final Animation<double> _logoScale = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: const Interval(0.15, 0.8, curve: Curves.easeOut));
  late final Animation<double> _textFade = CurvedAnimation(parent: _c, curve: const Interval(0.45, 1.0, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _c.forward();
    // Анимация + қысқа брендинг паузасынан кейін негізгі ағынға өтеміз.
    Future<void>.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDF8), Color(0xFFF3E9D4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(flex: 5),
              ScaleTransition(
                scale: Tween<double>(begin: 0.7, end: 1).animate(_logoScale),
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withValues(alpha: 0.28), blurRadius: 40, spreadRadius: 4),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/icon/altyn_icon.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text('ALTYN',
                        style: AppTypography.display(color: AppColors.gold).copyWith(fontSize: 40, letterSpacing: 3)),
                    const SizedBox(height: 8),
                    Text(l.splash_tagline,
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const Spacer(flex: 6),
              FadeTransition(
                opacity: _textFade,
                child: const SizedBox(
                  width: 26, height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

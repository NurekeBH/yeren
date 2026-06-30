import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/premium.dart';
import '../application/intro_controller.dart';

class _Slide {
  const _Slide(this.icon, this.title, this.text);
  final IconData icon;
  final String title;
  final String text;
}

/// Онбординг 2.0 — премиум-таныстыру (маркетинг hooks + плавный parallax + сильный CTA).
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(introControllerProvider.notifier).complete();
    if (mounted) context.go('/home');
  }

  void _next(int last) {
    if (_page >= last) {
      _finish();
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  // Текущая позиция прокрутки (дробная) — для parallax.
  double get _offset =>
      _pc.hasClients && _pc.position.haveDimensions ? (_pc.page ?? _page.toDouble()) : _page.toDouble();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slides = [
      _Slide(Icons.shield_rounded, l.intro_s1_title, l.intro_s1_text),
      _Slide(Icons.verified_rounded, l.intro_s2_title, l.intro_s2_text),
      _Slide(Icons.school_rounded, l.intro_s3_title, l.intro_s3_text),
      _Slide(Icons.groups_rounded, l.intro_s4_title, l.intro_s4_text),
    ];
    final last = slides.length - 1;
    final isLast = _page == last;

    return Scaffold(
      body: Container(
        // Сдержанный премиум-градиент фона (светлая тема).
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), AppColors.obsidian, Color(0xFFEEF1FF)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l.intro_skip, style: AppTypography.button(color: AppColors.textMuted)),
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _pc,
                  builder: (context, _) {
                    return PageView.builder(
                      controller: _pc,
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) => _SlideView(
                        slide: slides[i],
                        delta: _offset - i,
                        showSocialProof: i == last,
                        socialProof: l.intro_social_proof,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: i == _page
                            ? const LinearGradient(colors: [AppColors.gold, AppColors.goldBright])
                            : null,
                        color: i == _page ? null : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: PremiumButton(
                  label: isLast ? l.intro_start : l.intro_next,
                  icon: isLast ? Icons.arrow_forward_rounded : null,
                  onPressed: () => _next(last),
                  caption: isLast ? l.intro_social_proof : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.delta,
    required this.showSocialProof,
    required this.socialProof,
  });

  final _Slide slide;
  final double delta;
  final bool showSocialProof;
  final String socialProof;

  @override
  Widget build(BuildContext context) {
    // Parallax: бейдж и текст слегка «отстают» при свайпе (ощущение глубины).
    final fade = (1 - delta.abs()).clamp(0.0, 1.0);
    final badgeShift = delta * -36;
    final textShift = delta * -18;
    final scale = (1 - delta.abs() * 0.08).clamp(0.9, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(badgeShift, 0),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: fade,
                child: _Badge(icon: slide.icon),
              ),
            ),
          ),
          const SizedBox(height: 44),
          Transform.translate(
            offset: Offset(textShift, 0),
            child: Opacity(
              opacity: fade,
              child: Column(
                children: [
                  if (showSocialProof) ...[
                    _SocialProofChip(text: socialProof),
                    const SizedBox(height: 16),
                  ],
                  Text(slide.title, style: AppTypography.display(), textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  Text(
                    slide.text,
                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Премиум-бейдж: градиентное кольцо + мягкое свечение бренд-цвета.
class _Badge extends StatelessWidget {
  const _Badge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldBright],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.32), blurRadius: 34, offset: const Offset(0, 14)),
        ],
      ),
      child: Center(
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 52, color: Colors.white),
        ),
      ),
    );
  }
}

/// Соц-доказательство: компактный «живой» чип.
class _SocialProofChip extends StatelessWidget {
  const _SocialProofChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.profitGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.profitGreen.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

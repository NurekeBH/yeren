import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../l10n/gen/app_localizations.dart';

/// Авторизация керек экрандарды қаптайды.
/// Unauthenticated жағдайда:
///  • Артқы бет көрінеді, бірақ blur + dim
///  • Орталықта "Кіру/Тіркелу" карточкасы
///  • Бет элементтерімен әрекет жасау мүмкін емес
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthed = ref.watch(authControllerProvider).status == AuthStatus.authenticated;
    if (isAuthed) return child;

    final l = AppLocalizations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(ignoring: true, child: child),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                    ),
                    const Icon(Icons.lock_outline, size: 48, color: AppColors.gold),
                    const SizedBox(height: 14),
                    Text(
                      l.auth_login_required,
                      style: AppTypography.h2(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => context.push('/auth/phone?mode=login'),
                      child: Text(l.auth_login_button),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => context.push('/auth/phone?mode=register'),
                      child: Text(l.auth_register_button),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

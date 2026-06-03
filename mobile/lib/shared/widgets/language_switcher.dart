import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);
    final fg = onDark ? Colors.white : AppColors.textPrimary;

    return PopupMenuButton<Locale>(
      tooltip: 'Тіл / Язык / Language',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, color: fg, size: 18),
          const SizedBox(width: 6),
          Text(current.languageCode.toUpperCase(), style: AppTypography.label(color: fg)),
        ],
      ),
      onSelected: controller.set,
      itemBuilder: (context) => const [
        PopupMenuItem(value: Locale('kk'), child: Text('Қазақша')),
        PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
        PopupMenuItem(value: Locale('en'), child: Text('English')),
      ],
    );
  }
}

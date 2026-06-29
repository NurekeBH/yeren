import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';

/// Қала енгізу — теру арқылы DB-ден autocomplete (тұрақты тізім: фильтр/нотификация/аналитика).
/// Еркін мәтінге де рұқсат (тізімде жоқ қала). onChanged — әр өзгерісте де, таңдағанда да.
class CityField extends ConsumerWidget {
  const CityField({super.key, required this.initial, required this.onChanged, this.label, this.hint});

  final String initial;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initial),
      optionsBuilder: (value) async {
        final q = value.text.trim();
        if (q.isEmpty) return const Iterable<String>.empty();
        try {
          return await ref.read(apiServiceProvider).cities(q);
        } catch (_) {
          return const Iterable<String>.empty();
        }
      },
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: const Icon(Icons.location_city_outlined, size: 18),
          ),
          onChanged: onChanged,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final list = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                  title: Text(list[i]),
                  onTap: () => onSelected(list[i]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

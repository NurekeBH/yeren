import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Телефон тіркеуі үшін ел кодтары. Әдепкі — Қазақстан (+7).
class Country {
  const Country(this.flag, this.name, this.dial, this.iso);
  final String flag; // эмодзи ту
  final String name;
  final String dial; // елдік код (+ белгісіз)
  final String iso; // ISO-2 (бірегейлік үшін, +7-ні KZ/RU ажырату)
}

/// Орталық Азия басымдықпен (пайдаланушылар көп), сосын ТМД + жиі елдер.
/// Реті: Қазақстан (әдепкі) → Өзбекстан → Қырғызстан → қалғаны.
const List<Country> kCountries = [
  Country('🇰🇿', 'Қазақстан', '7', 'KZ'),
  Country('🇺🇿', 'Oʻzbekiston', '998', 'UZ'),
  Country('🇰🇬', 'Кыргызстан', '996', 'KG'),
  Country('🇷🇺', 'Россия', '7', 'RU'),
  Country('🇹🇯', 'Тоҷикистон', '992', 'TJ'),
  Country('🇹🇲', 'Türkmenistan', '993', 'TM'),
  Country('🇦🇿', 'Azərbaycan', '994', 'AZ'),
  Country('🇬🇪', 'საქართველო', '995', 'GE'),
  Country('🇦🇲', 'Հայաստան', '374', 'AM'),
  Country('🇧🇾', 'Беларусь', '375', 'BY'),
  Country('🇺🇦', 'Україна', '380', 'UA'),
  Country('🇲🇩', 'Moldova', '373', 'MD'),
  Country('🇹🇷', 'Türkiye', '90', 'TR'),
  Country('🇦🇪', 'UAE', '971', 'AE'),
  Country('🇨🇳', 'China', '86', 'CN'),
  Country('🇩🇪', 'Deutschland', '49', 'DE'),
  Country('🇬🇧', 'United Kingdom', '44', 'GB'),
  Country('🇺🇸', 'United States', '1', 'US'),
];

const Country kDefaultCountry = Country('🇰🇿', 'Қазақстан', '7', 'KZ');

/// Ел таңдау sheet-і (іздеуі бар). Таңдалған елді қайтарады, бас тартса — null.
Future<Country?> showCountryPicker(BuildContext context, Country current) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.obsidian,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CountryPicker(current: current),
  );
}

class _CountryPicker extends StatefulWidget {
  const _CountryPicker({required this.current});
  final Country current;

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final q = _q.trim().toLowerCase();
    final items = q.isEmpty
        ? kCountries
        : kCountries
            .where((c) => c.name.toLowerCase().contains(q) || c.dial.contains(q) || c.iso.toLowerCase().contains(q))
            .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'Поиск / Іздеу…',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final c = items[i];
                  final selected = c.iso == widget.current.iso;
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(c.name, style: AppTypography.bodyMedium()),
                    trailing: Text('+${c.dial}',
                        style: AppTypography.price(size: 15, color: AppColors.textSecondary)),
                    selected: selected,
                    selectedTileColor: AppColors.gold.withValues(alpha: 0.08),
                    onTap: () => Navigator.of(context).pop(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

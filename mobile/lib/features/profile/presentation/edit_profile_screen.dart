import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/profile_controller.dart';

/// Профильді өңдеу: аты, қаласы, bio, сауда стильдері.
/// (Сауда сессиясын таңдау алынып тасталды.)
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _bio;
  late Set<TradingStyle> _styles;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileControllerProvider);
    _name = TextEditingController(text: p.name);
    _city = TextEditingController(text: p.city);
    _bio = TextEditingController(text: p.bio);
    _styles = Set<TradingStyle>.from(p.styles);
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l) {
    if (!_formKey.currentState!.validate()) return;
    if (_styles.isEmpty) return;
    ref.read(profileControllerProvider.notifier).updateProfile(
          name: _name.text.trim(),
          city: _city.text.trim(),
          bio: _bio.text.trim(),
          styles: _styles,
        );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.profile_saved_toast)));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.profile_edit)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Text(l.onboarding_name_label, style: AppTypography.label()),
              const SizedBox(height: 6),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(hintText: l.onboarding_name_hint),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.common_error : null,
              ),
              const SizedBox(height: 16),
              Text(l.onboarding_city_label, style: AppTypography.label()),
              const SizedBox(height: 6),
              TextFormField(controller: _city, decoration: InputDecoration(hintText: l.onboarding_city_hint)),
              const SizedBox(height: 16),
              Text(l.onboarding_style_label, style: AppTypography.label()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in TradingStyle.values)
                    FilterChip(
                      label: Text(tradingStyleLabel(s, l)),
                      selected: _styles.contains(s),
                      onSelected: (v) => setState(() {
                        v ? _styles.add(s) : _styles.remove(s);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l.profile_about_me, style: AppTypography.label()),
              const SizedBox(height: 6),
              TextFormField(controller: _bio, maxLength: 200, maxLines: 3),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => _save(l), child: Text(l.common_save)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/city_field.dart';
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
  String _cityValue = ''; // CityField autocomplete мәні
  late final TextEditingController _bio;
  late Set<TradingStyle> _styles;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileControllerProvider);
    _name = TextEditingController(text: p.name);
    _cityValue = p.city;
    _bio = TextEditingController(text: p.bio);
    _styles = Set<TradingStyle>.from(p.styles);
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l) {
    if (!_formKey.currentState!.validate()) return;
    // Сауда стилі ОПЦИОНАЛ — бос болса да сақтаймыз.
    ref.read(profileControllerProvider.notifier).updateProfile(
          name: _name.text.trim(),
          city: _cityValue.trim(),
          bio: _bio.text.trim(),
          styles: _styles,
        );
    // Сақтаған соң бірден профиль бетіне ораламыз (messenger-ді алдын ала аламыз,
    // pop-тан кейін context деактив болуы мүмкін).
    final messenger = ScaffoldMessenger.of(context);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
    messenger.showSnackBar(SnackBar(content: Text(l.profile_saved_toast)));
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
              CityField(initial: _cityValue, hint: l.onboarding_city_hint, onChanged: (v) => _cityValue = v),
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

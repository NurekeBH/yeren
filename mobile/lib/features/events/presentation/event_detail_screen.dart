import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/mock/events_fixtures.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/trading_event.dart';
import '../../../shared/widgets/error_view.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';
import 'events_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  YoutubePlayerController? _yt;

  @override
  void initState() {
    super.initState();
    final events = ref.read(eventsProvider).valueOrNull ?? const [];
    final matches = events.where((e) => e.id == widget.eventId);
    final yid = matches.isEmpty ? null : matches.first.youtubeId;
    if (yid != null) {
      _yt = YoutubePlayerController.fromVideoId(
        videoId: yid,
        autoPlay: false,
        params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
      );
    }
  }

  @override
  void dispose() {
    _yt?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final events = ref.watch(eventsProvider).valueOrNull ?? const [];
    final matches = events.where((e) => e.id == widget.eventId);
    if (matches.isEmpty) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final e = matches.first;
    final grad = eventGradients[e.type]!;

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showApplySheet(e, l),
            icon: const Icon(Icons.how_to_reg),
            label: Text('${l.event_apply}${e.isFree ? '' : ' · ${e.price.toStringAsFixed(0)} ₸'}'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            height: e.posterUrl != null ? 200 : 140,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Мұқаба суреті болса — фон ретінде (мәтін оқылуы үшін қара градиент scrim).
                if (e.posterUrl != null) ...[
                  CachedNetworkImage(
                    imageUrl: e.posterUrl!,
                    fit: BoxFit.cover,
                    memCacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${e.type.emoji}  ${eventTypeLabel(e.type, l).toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      Text(e.title,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.person_outline, text: e.speaker),
          _InfoRow(icon: Icons.schedule, text: eventDate(e.dateIso)),
          _InfoRow(icon: e.isOnline ? Icons.wifi : Icons.location_on_outlined, text: e.city),
          _InfoRow(
            icon: Icons.sell_outlined,
            text: e.isFree ? l.event_free : '${e.price.toStringAsFixed(0)} ₸',
            color: e.isFree ? AppColors.profitGreen : AppColors.gold,
          ),
          const SizedBox(height: 18),
          if (_yt != null) ...[
            Text(l.event_video, style: AppTypography.label(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(controller: _yt!, aspectRatio: 16 / 9),
            ),
            const SizedBox(height: 18),
          ],
          Text(l.event_about, style: AppTypography.label(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(e.description, style: AppTypography.bodyMedium().copyWith(height: 1.5)),
        ],
      ),
    );
  }

  void _showApplySheet(TradingEvent e, AppLocalizations l) {
    final profile = ref.read(profileControllerProvider);
    final phone = ref.read(authControllerProvider).phone ?? '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.obsidian,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ApplySheet(event: e, l: l, name: profile.name, phone: phone),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(text, style: AppTypography.bodyMedium(color: color ?? AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ApplySheet extends ConsumerStatefulWidget {
  const _ApplySheet({required this.event, required this.l, required this.name, required this.phone});
  final TradingEvent event;
  final AppLocalizations l;
  final String name;
  final String phone;

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  late final TextEditingController _name = TextEditingController(text: widget.name);
  late final TextEditingController _phone = TextEditingController(text: widget.phone);
  final TextEditingController _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = widget.l;
    if (AppConfig.useRemoteApi) {
      setState(() => _busy = true);
      try {
        await ref.read(apiServiceProvider).applyToEvent(
              widget.event.id,
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              comment: _comment.text.trim(),
            );
      } catch (e) {
        if (!mounted) return;
        setState(() => _busy = false);
        final msg = friendlyErrorText(e, l);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.apply_sent)));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.apply_title, style: AppTypography.h2()),
          const SizedBox(height: 4),
          Text(widget.event.title, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(l.apply_autofill_note, style: AppTypography.label(color: AppColors.textMuted)),
          const SizedBox(height: 14),
          TextField(controller: _name, decoration: InputDecoration(labelText: l.apply_name, border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l.apply_phone, border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _comment, maxLines: 2, decoration: InputDecoration(labelText: l.apply_comment, border: const OutlineInputBorder())),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.apply_submit),
            ),
          ),
        ],
      ),
    );
  }
}

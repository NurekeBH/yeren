import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/events_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/trading_event.dart';
import '../../profile/application/profile_controller.dart';
import 'publish_event_sheet.dart';

String eventDate(String iso) {
  final d = DateTime.parse(iso).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)} · ${two(d.hour)}:${two(d.minute)}';
}

String eventTypeLabel(EventType t, AppLocalizations l) {
  switch (t) {
    case EventType.masterclass:
      return l.event_type_masterclass;
    case EventType.liveTrade:
      return l.event_type_live;
    case EventType.webinar:
      return l.event_type_webinar;
  }
}

const eventGradients = <EventType, List<Color>>{
  EventType.masterclass: [Color(0xFF4A2C5A), Color(0xFF7A4C8F)],
  EventType.liveTrade: [Color(0xFF1F4D3F), Color(0xFF2F7D63)],
  EventType.webinar: [Color(0xFF22324F), Color(0xFF3E5C8A)],
};

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(eventsProvider);
    final isTrader = ref.watch(profileControllerProvider).isVerifiedTrader;

    return Scaffold(
      appBar: AppBar(title: Text(l.events_title)),
      floatingActionButton: isTrader
          ? FloatingActionButton.extended(
              onPressed: () => showPublishEventSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l.event_publish),
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          ref.invalidate(eventsProvider);
          await ref.read(eventsProvider.future);
        },
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l.common_error}: $e')),
          data: (events) => events.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.26),
                    const Icon(Icons.event_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 14),
                    Text(l.events_empty,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: events.length,
                  itemBuilder: (_, i) => _EventCard(event: events[i], l: l),
                ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.l});

  final TradingEvent event;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final grad = eventGradients[event.type]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => GoRouter.of(context).push('/events/${event.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Афиша
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(event.type.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(eventTypeLabel(event.type, l).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ],
                    ),
                    const Spacer(),
                    Text(event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.2)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.speaker, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(eventDate(event.dateIso), style: AppTypography.label(color: AppColors.textSecondary)),
                              const SizedBox(width: 10),
                              Icon(event.isOnline ? Icons.wifi : Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(event.city, style: AppTypography.label(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _PriceChip(event: event, l: l),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.event, required this.l});
  final TradingEvent event;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final free = event.isFree;
    final color = free ? AppColors.profitGreen : AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(
        free ? l.event_free : '${event.price.toStringAsFixed(0)} ₸',
        style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

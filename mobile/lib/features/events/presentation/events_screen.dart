import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/events_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/trading_event.dart';
import '../../../shared/widgets/error_view.dart';
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

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  EventType? _type; // null = барлығы
  bool? _online; // null=барлығы, true=онлайн, false=оффлайн
  bool? _free; // null=барлығы, true=тегін, false=ақылы
  String? _city; // null=барлық қалалар

  List<TradingEvent> _apply(List<TradingEvent> all) => all.where((e) {
        if (_type != null && e.type != _type) return false;
        if (_online != null && e.isOnline != _online) return false;
        if (_free != null && e.isFree != _free) return false;
        if (_city != null && e.city != _city) return false;
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
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
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(eventsProvider)),
        data: (events) {
          // Бэкендте мүлде оқиға жоқ — «жақында» бос күй (фильтрсіз).
          if (events.isEmpty) {
            return RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () async {
                ref.invalidate(eventsProvider);
                await ref.read(eventsProvider.future);
              },
              child: ListView(
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
              ),
            );
          }

          final cities = (events.map((e) => e.city).where((c) => c.trim().isNotEmpty).toSet().toList())..sort();
          final filtered = _apply(events);

          return Column(
            children: [
              _FilterBar(
                l: l,
                type: _type,
                online: _online,
                free: _free,
                city: _city,
                cities: cities,
                onType: (t) => setState(() => _type = t),
                onOnline: (v) => setState(() => _online = v),
                onFree: (v) => setState(() => _free = v),
                onCity: (c) => setState(() => _city = c),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async {
                    ref.invalidate(eventsProvider);
                    await ref.read(eventsProvider.future);
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                            const Icon(Icons.filter_alt_off_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(l.events_none_match,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _EventCard(event: filtered[i], l: l),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Іс-шара сүзгілері: түрі, формат (онлайн/оффлайн), баға (тегін/ақылы), қала.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.l,
    required this.type,
    required this.online,
    required this.free,
    required this.city,
    required this.cities,
    required this.onType,
    required this.onOnline,
    required this.onFree,
    required this.onCity,
  });

  final AppLocalizations l;
  final EventType? type;
  final bool? online;
  final bool? free;
  final String? city;
  final List<String> cities;
  final ValueChanged<EventType?> onType;
  final ValueChanged<bool?> onOnline;
  final ValueChanged<bool?> onFree;
  final ValueChanged<String?> onCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // 1-жол: түрі
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(label: l.events_filter_all, selected: type == null, onTap: () => onType(null)),
                _Chip(label: '🎓 ${l.event_type_masterclass}', selected: type == EventType.masterclass, onTap: () => onType(EventType.masterclass)),
                _Chip(label: '📊 ${l.event_type_live}', selected: type == EventType.liveTrade, onTap: () => onType(EventType.liveTrade)),
                _Chip(label: '💻 ${l.event_type_webinar}', selected: type == EventType.webinar, onTap: () => onType(EventType.webinar)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // 2-жол: формат + баға + қала
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(label: l.events_filter_online, selected: online == true, onTap: () => onOnline(online == true ? null : true)),
                _Chip(label: l.events_filter_offline, selected: online == false, onTap: () => onOnline(online == false ? null : false)),
                const SizedBox(width: 4),
                _Chip(label: l.events_filter_free, selected: free == true, onTap: () => onFree(free == true ? null : true)),
                _Chip(label: l.events_filter_paid, selected: free == false, onTap: () => onFree(free == false ? null : false)),
                if (cities.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _CityDropdown(l: l, city: city, cities: cities, onCity: onCity),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold.withValues(alpha: 0.16) : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.gold : AppColors.border),
          ),
          child: Text(
            label,
            style: AppTypography.label(color: selected ? AppColors.gold : AppColors.textSecondary)
                .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.l, required this.city, required this.cities, required this.onCity});
  final AppLocalizations l;
  final String? city;
  final List<String> cities;
  final ValueChanged<String?> onCity;

  @override
  Widget build(BuildContext context) {
    final selected = city != null;
    return PopupMenuButton<String?>(
      onSelected: (v) => onCity(v == '' ? null : v),
      itemBuilder: (_) => [
        PopupMenuItem<String?>(value: '', child: Text(l.events_filter_all)),
        ...cities.map((c) => PopupMenuItem<String?>(value: c, child: Text(c))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.16) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(city ?? l.events_filter_city,
                style: AppTypography.label(color: selected ? AppColors.gold : AppColors.textSecondary)
                    .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
          ],
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

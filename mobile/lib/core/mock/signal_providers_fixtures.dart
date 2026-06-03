import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/signal_provider.dart';
import '../locale/locale_controller.dart';

/// Сигнал провайдерлерінің каталогы (мок). Bio `loc` бойынша таңдалады.
class SignalProvidersFixtures {
  SignalProvidersFixtures._();

  static String _pick(String loc, Map<String, String> m) =>
      m[loc] ?? m['ru'] ?? m['kk'] ?? m.values.first;

  static List<SignalProvider> all(String loc) {
    String t(String kk, String ru, String en) => _pick(loc, {'kk': kk, 'ru': ru, 'en': en});
    return [
      SignalProvider(
        id: 'pr-1', name: 'TraderOS Desk', avatar: '🏆',
        winRate: 0.72, avgRr: 2.3, rating: 4.8, subscribers: 1240,
        pricePerMonth: 0, verified: true, tradesCount: 318,
        bio: t('Ресми TraderOS деск. XAU/USD бойынша London/NY overlap сетаптары, қатаң risk-менеджмент.',
            'Официальный деск TraderOS. Сетапы по XAU/USD на overlap London/NY, строгий риск-менеджмент.',
            'The official TraderOS desk. XAU/USD setups on the London/NY overlap, strict risk management.'),
      ),
      SignalProvider(
        id: 'pr-2', name: 'Алмас Gold', avatar: '🦅',
        winRate: 0.66, avgRr: 2.1, rating: 4.5, subscribers: 860,
        pricePerMonth: 30000, verified: true, tradesCount: 412,
        bio: t('5 жылдық тәжірибе, тек XAU/USD. Күніне 1–3 сапалы идея, скриншотпен.',
            '5 лет опыта, только XAU/USD. 1–3 качественные идеи в день со скриншотами.',
            '5 years of experience, XAU/USD only. 1–3 quality ideas per day with screenshots.'),
      ),
      SignalProvider(
        id: 'pr-3', name: 'SMC Pro', avatar: '📊',
        winRate: 0.69, avgRr: 2.6, rating: 4.6, subscribers: 540,
        pricePerMonth: 20000, verified: true, tradesCount: 205,
        bio: t('Smart Money Concepts: order block, liquidity sweep, BOS/CHoCH. Топ-даун талдау.',
            'Smart Money Concepts: order block, liquidity sweep, BOS/CHoCH. Топ-даун анализ.',
            'Smart Money Concepts: order blocks, liquidity sweeps, BOS/CHoCH. Top-down analysis.'),
      ),
      SignalProvider(
        id: 'pr-4', name: 'Asia Session', avatar: '🌏',
        winRate: 0.58, avgRr: 1.9, rating: 4.0, subscribers: 310,
        pricePerMonth: 0, verified: false, tradesCount: 156,
        bio: t('Азия сессиясының range-trading идеялары. Тегін, бірақ жаңа провайдер.',
            'Идеи range-trading в азиатскую сессию. Бесплатно, но новый провайдер.',
            'Asia-session range-trading ideas. Free, but a new provider.'),
      ),
      SignalProvider(
        id: 'pr-5', name: 'London Killzone', avatar: '🇬🇧',
        winRate: 0.63, avgRr: 2.2, rating: 4.3, subscribers: 470,
        pricePerMonth: 15000, verified: true, tradesCount: 289,
        bio: t('Лондон ашылуындағы killzone сетаптары. ICT тәсілі, нақты кіру/шығу.',
            'Killzone-сетапы на открытии Лондона. Подход ICT, чёткие вход/выход.',
            'Killzone setups at the London open. ICT approach, clear entries/exits.'),
      ),
    ];
  }
}

final signalProvidersProvider = Provider<List<SignalProvider>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return SignalProvidersFixtures.all(loc);
});

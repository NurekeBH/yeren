import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traderos/core/locale/locale_controller.dart';
import 'package:traderos/main.dart';

void main() {
  testWidgets('home screen is initial route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const TraderOSApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Home Scaffold-ы Live Ticker bar-да XAU/USD белгісімен жүктеледі.
    expect(find.text('XAU/USD'), findsWidgets);
  });
}

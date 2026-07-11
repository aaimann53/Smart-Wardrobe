import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartwardrobe/main.dart';
import 'package:smartwardrobe/screens/home_body.dart';
import 'package:smartwardrobe/screens/wardrobe_body.dart';
import 'package:smartwardrobe/utils/app_state.dart';

void main() {
  testWidgets('MyApp renders the splash screen title', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
    );

    expect(find.text('Smart Wardrobe'), findsOneWidget);
  });

  testWidgets('Wardrobe view shows an add clothing action', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(home: WardrobeBody()),
      ),
    );

    expect(find.text('Add Clothing'), findsOneWidget);
  });

  testWidgets('Home dashboard shows the carousel slides', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(home: HomeDashboardBody()),
      ),
    );

    expect(find.text('Summer Clothes'), findsOneWidget);
  });

  test('AppState seeds wardrobe items and removes planned outfits safely', () {
    final state = AppState();

    expect(state.clothingItems, isNotEmpty);
    expect(state.clothingItems.first.name, 'White Linen Shirt');

    state.addPlannedOutfit(DateTime(2026, 7, 8), {
      'title': 'Test Outfit',
      'time': '10:00 AM',
      'image': '',
    });

    expect(state.getOutfitsForDate(DateTime(2026, 7, 8)), hasLength(1));

    state.removePlannedOutfit(DateTime(2026, 7, 8), 0);
    expect(state.getOutfitsForDate(DateTime(2026, 7, 8)), isEmpty);

    state.removePlannedOutfit(DateTime(2026, 7, 8), 99);
    expect(state.getOutfitsForDate(DateTime(2026, 7, 8)), isEmpty);
  });
}

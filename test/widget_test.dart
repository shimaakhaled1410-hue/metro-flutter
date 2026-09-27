import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro/main.dart';
import 'package:metro/views/splash_view.dart';

void main() {
  testWidgets('MonoMetro App launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MonoMetroApp(
        initialThemeMode: ThemeMode.light,
        initialLocale: Locale('en', 'US'),
      ),
    );

    expect(find.byType(SplashView), findsOneWidget);
  });
}
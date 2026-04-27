import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storm/app/app.dart';

import '../../helpers/helpers.dart';

void main() {
  group('App', () {
    testWidgets('displays the app title in app bar and page body', (
      tester,
    ) async {
      await tester.pumpApp(const App());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Storm'), findsNWidgets(2));
    });
  });
}

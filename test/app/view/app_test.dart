// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storm/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders Page', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

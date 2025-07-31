import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_rent_car/main.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts successfully
    expect(find.text('Offline Car Rental Manager'), findsOneWidget);
  });
} 
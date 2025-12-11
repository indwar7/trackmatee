// This is a basic Flutter widget test for TrackMate app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackmate_app/main.dart';
import 'package:trackmate_app/widgets/edit_trip_dialog.dart';

void main() {
  testWidgets('TrackMate app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrackMateApp(initialRoute: '/welcome',));

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app launches (you can check for any initial screen elements)
    // This is a basic smoke test to ensure the app doesn't crash on startup
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('EditTripDialog displays correctly', (WidgetTester tester) async {
    // Create a test wrapper for the dialog
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTripDialog(
                      tripId: 1,
                      currentFuelExpense: 100.0,
                      currentParkingCost: 50.0,
                      currentTollCost: 30.0,
                      onSuccess: () {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog elements are displayed
    expect(find.text('Edit Trip Expenses'), findsOneWidget);
    expect(find.text('Fuel Expense'), findsOneWidget);
    expect(find.text('Parking Cost'), findsOneWidget);
    expect(find.text('Toll Cost'), findsOneWidget);
    expect(find.text('Total Expense'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('EditTripDialog pre-fills with current values', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTripDialog(
                      tripId: 1,
                      currentFuelExpense: 150.0,
                      currentParkingCost: 75.0,
                      currentTollCost: 25.0,
                      onSuccess: () {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify pre-filled values
    expect(find.text('150.0'), findsOneWidget);
    expect(find.text('75.0'), findsOneWidget);
    expect(find.text('25.0'), findsOneWidget);

    // Verify total calculation
    expect(find.text('₹ 250.00'), findsOneWidget);
  });

  testWidgets('EditTripDialog calculates total correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTripDialog(
                      tripId: 1,
                      onSuccess: () {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Enter values in text fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter fuel cost'), '100');
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter parking cost'), '50');
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter toll cost'), '25');
    await tester.pumpAndSettle();

    // Verify total is calculated correctly
    expect(find.text('₹ 175.00'), findsOneWidget);
  });

  testWidgets('EditTripDialog validates negative amounts', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTripDialog(
                      tripId: 1,
                      onSuccess: () {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Enter negative value
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter fuel cost'), '-100');
    await tester.pumpAndSettle();

    // Try to submit
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    // Verify error message appears
    expect(find.text('Amount cannot be negative'), findsOneWidget);
  });

  testWidgets('EditTripDialog closes on cancel', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTripDialog(
                      tripId: 1,
                      onSuccess: () {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog is open
    expect(find.text('Edit Trip Expenses'), findsOneWidget);

    // Tap cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify dialog is closed
    expect(find.text('Edit Trip Expenses'), findsNothing);
  });
}
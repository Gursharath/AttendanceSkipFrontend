import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bunk/main.dart';

void main() {
  testWidgets('HomeScreen loads and shows empty state', (
    WidgetTester tester,
  ) async {
    // Load the Attendance App
    await tester.pumpWidget(const AttendanceApp());

    // Expect the app bar title
    expect(find.text('Attendance Simulator'), findsOneWidget);

    // Should show empty message initially
    expect(find.text('No courses added yet.'), findsOneWidget);
  });

  testWidgets('Add a course and verify it appears', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AttendanceApp());

    // Tap the floating action button to add course
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.bySemanticsLabel('Course Name'), 'Math');
    await tester.enterText(find.bySemanticsLabel('Total Classes'), '20');
    await tester.enterText(find.bySemanticsLabel('Classes Attended'), '15');

    // Submit
    await tester.tap(find.text('Add Course'));
    await tester.pumpAndSettle();

    // Check if the new course appears
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('15/20'), findsOneWidget);
  });
}

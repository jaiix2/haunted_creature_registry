import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_club_signup/main.dart';
import 'package:gaming_club_signup/screens/signup_screen.dart';
import 'package:gaming_club_signup/screens/success_screen.dart';

Future<void> _openSignup(WidgetTester tester) async {
  await tester.pumpWidget(const HauntedMansionApp());
  await tester.tap(find.text('Enter the Registry'));
  await tester.pumpAndSettle();
}

Future<void> _completeSignup(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('nameField')), 'Night Rider');
  await tester.enterText(
    find.byKey(const Key('emailField')),
    'player@example.com',
  );
  await tester.enterText(find.byKey(const Key('passwordField')), 'RaidSafe9');

  await tester.ensureVisible(find.byKey(const Key('creatureDropdown')));
  await tester.tap(find.byKey(const Key('creatureDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ghost').last);
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byKey(const Key('birthDateField')));
  await tester.tap(find.byKey(const Key('birthDateField')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('welcome screen opens signup and back returns to welcome', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HauntedMansionApp());
    expect(find.text('Enter the Registry'), findsOneWidget);

    await tester.tap(find.text('Enter the Registry'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Enter the Registry'), findsOneWidget);
  });

  testWidgets('empty submission shows all required field errors', (
    WidgetTester tester,
  ) async {
    await _openSignup(tester);
    await tester.ensureVisible(find.byKey(const Key('signupButton')));
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();

    expect(find.text('Please enter your gamer name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Choose a creature type'), findsOneWidget);
    expect(find.text('Pick your birth date'), findsOneWidget);
  });

  testWidgets('invalid name email and password are rejected', (
    WidgetTester tester,
  ) async {
    await _openSignup(tester);
    await tester.enterText(find.byKey(const Key('nameField')), 'A');
    await tester.enterText(find.byKey(const Key('emailField')), 'not-an-email');
    await tester.enterText(find.byKey(const Key('passwordField')), 'short');
    await tester.ensureVisible(find.byKey(const Key('signupButton')));
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();

    expect(
      find.text('Gamer name must be at least 2 characters'),
      findsOneWidget,
    );
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('password visibility toggles and all creature choices appear', (
    WidgetTester tester,
  ) async {
    await _openSignup(tester);
    final passwordField = find.byKey(const Key('passwordField'));
    final textField = find.descendant(
      of: passwordField,
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(textField).obscureText, isTrue);

    await tester.tap(find.byKey(const Key('togglePasswordVisibility')));
    await tester.pump();
    expect(tester.widget<TextField>(textField).obscureText, isFalse);

    await tester.ensureVisible(find.byKey(const Key('creatureDropdown')));
    await tester.tap(find.byKey(const Key('creatureDropdown')));
    await tester.pumpAndSettle();
    for (final creature in [
      'Ghost',
      'Bat',
      'Black Cat',
      'Pumpkin Spirit',
      'Witch',
    ]) {
      expect(find.text(creature), findsOneWidget);
    }
  });

  testWidgets('birth date picker does not allow a future date', (
    WidgetTester tester,
  ) async {
    await _openSignup(tester);
    await tester.ensureVisible(find.byKey(const Key('birthDateField')));
    await tester.tap(find.byKey(const Key('birthDateField')));
    await tester.pumpAndSettle();

    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final today = DateTime.now();
    expect(calendar.lastDate, DateTime(today.year, today.month, today.day));
  });

  testWidgets('valid signup shows loading then success and returns to foyer', (
    WidgetTester tester,
  ) async {
    await _openSignup(tester);
    await _completeSignup(tester);

    await tester.ensureVisible(find.byKey(const Key('signupButton')));
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('signupButton')))
          .onPressed,
      isNull,
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SuccessScreen), findsOneWidget);
    expect(find.text('Welcome, Night Rider!'), findsOneWidget);
    expect(find.text('Creature registered: Ghost.'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SuccessScreen), findsOneWidget);

    await tester.tap(find.text('Back to the Foyer'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the Registry'), findsOneWidget);
  });

  testWidgets('local signup tip still shows error and retry success', (
    WidgetTester tester,
  ) async {
    await _openSignup(tester);

    await tester.ensureVisible(find.byKey(const Key('getTip')));
    await tester.tap(find.byKey(const Key('getTip')));
    await tester.pump();
    expect(find.text('Preparing a local preset…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 650));
    expect(
      find.text('The local preset demo ran into a sample error.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('retryTip')));
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('Preset demo tip—not live AI.'), findsOneWidget);
    expect(
      find.text(
        'Use a unique passphrase of four unrelated words, then add a symbol you can remember.',
      ),
      findsOneWidget,
    );
  });
}

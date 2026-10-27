import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_club_signup/main.dart';

void main() {
  testWidgets('validates invalid form input', (WidgetTester tester) async {
    await tester.pumpWidget(const GamingSignupApp());

    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();

    expect(find.text('Please enter your gamer name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });

  testWidgets('accepts strong form input', (WidgetTester tester) async {
    await tester.pumpWidget(const GamingSignupApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Night Rider');
    await tester.enterText(find.byKey(const Key('emailField')), 'player@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'RaidSafe9');
    await tester.tap(find.byKey(const Key('signupButton')));
    await tester.pump();

    expect(find.text('Demo signup complete — validation passed!'), findsOneWidget);
  });

  testWidgets('preset tip shows loading, error, and retry success', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GamingSignupApp());

    await tester.ensureVisible(find.byKey(const Key('getTip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('getTip')));
    await tester.pump();
    expect(find.text('Preparing a local preset…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('The local preset demo ran into a sample error.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retryTip')));
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.text('Preset demo tip—not live AI.'), findsOneWidget);
    expect(find.text('Use a unique passphrase of four unrelated words, then add a symbol you can remember.'), findsOneWidget);
  });
}

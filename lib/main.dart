import 'package:flutter/material.dart';

import 'signup_page.dart';

void main() => runApp(const GamingSignupApp());

class GamingSignupApp extends StatelessWidget {
  const GamingSignupApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C4DFF);
    return MaterialApp(
      title: 'Guild Signup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF171426),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0B18),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF201C35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFF46405F)),
          ),
        ),
      ),
      home: const SignupPage(),
    );
  }
}

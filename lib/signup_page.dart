import 'dart:async';

import 'package:flutter/material.dart';

const _passwordHelpCategory = 'password_help';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

enum _TipStatus { idle, loading, success, error }

class _SignupPageState extends State<SignupPage> {
  static const _presetTips = <String, List<String>>{
    _passwordHelpCategory: <String>[
      'Use a unique passphrase of four unrelated words, then add a symbol you can remember.',
      'Choose 12 or more characters and use a password manager rather than reusing a password.',
      'Create a memorable phrase with mixed words, numbers, and symbols—never put it in a shared message.',
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _TipStatus _tipStatus = _TipStatus.idle;
  String _tip = '';
  int _tipRequestCount = 0;
  Timer? _tipTimer;

  @override
  void dispose() {
    _tipTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestTip() async {
    if (_tipStatus == _TipStatus.loading) return;

    _tipTimer?.cancel();
    _tipRequestCount++;
    final requestNumber = _tipRequestCount;
    setState(() => _tipStatus = _TipStatus.loading);

    _tipTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        if (requestNumber == 1) {
          _tipStatus = _TipStatus.error;
          return;
        }
        final tips = _presetTips[_passwordHelpCategory]!;
        _tip = tips[(requestNumber - 2) % tips.length];
        _tipStatus = _TipStatus.success;
      });
    });
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Please enter your gamer name';
    if (name.length < 2) return 'Gamer name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    final emailPattern = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
    );
    if (!emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter a password';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Add at least one number';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF257A53),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text('Demo signup complete — validation passed!'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIXEL RAIDERS'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _ArenaBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeroHeader(),
                      const SizedBox(height: 24),
                      Card(
                        color: const Color(0xB3191728),
                        elevation: 12,
                        shadowColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFF34304C)),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  key: const Key('nameField'),
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.nickname],
                                  decoration: const InputDecoration(
                                    labelText: 'Gamer name',
                                    hintText: 'NightRider',
                                    prefixIcon: Icon(
                                      Icons.sports_esports_outlined,
                                    ),
                                  ),
                                  validator: _validateName,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const Key('emailField'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                    labelText: 'Email address',
                                    hintText: 'player@example.com',
                                    prefixIcon: Icon(Icons.alternate_email),
                                  ),
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const Key('passwordField'),
                                  controller: _passwordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    helperText: '8+ characters with upper, lower, and number',
                                    prefixIcon: Icon(Icons.shield_outlined),
                                  ),
                                  validator: _validatePassword,
                                ),
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  key: const Key('signupButton'),
                                  onPressed: _submit,
                                  icon: const Icon(
                                    Icons.rocket_launch_outlined,
                                  ),
                                  label: const Text('Join the Guild'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: const Color(0xFF7C4DFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _TipCard(
                        status: _tipStatus,
                        tip: _tip,
                        onRequest: _requestTip,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.status,
    required this.tip,
    required this.onRequest,
  });

  final _TipStatus status;
  final String tip;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F33),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF303A5A)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF67D9FF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Password Coach',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (status == _TipStatus.loading) ...[
              const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Preparing a local preset…'),
                ],
              ),
            ] else if (status == _TipStatus.error) ...[
              const Text(
                'The local preset demo ran into a sample error.',
                style: TextStyle(color: Color(0xFFFFB4AB)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const Key('retryTip'),
                onPressed: onRequest,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ] else if (status == _TipStatus.success) ...[
              Text(tip, style: const TextStyle(height: 1.45)),
              const SizedBox(height: 10),
              const Text(
                'Preset demo tip—not live AI.',
                style: TextStyle(
                  color: Color(0xFF67D9FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else
              const Text(
                'Need a password idea? This local demo never reads your form.',
              ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const Key('getTip'),
                onPressed: status == _TipStatus.loading ? null : onRequest,
                icon: const Icon(Icons.tips_and_updates_outlined),
                label: const Text('Get a signup tip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0x3344B7FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.videogame_asset,
            size: 42,
            color: Color(0xFF67D9FF),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join the next raid',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Create your squad profile and get ready to play.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB9B6C9)),
        ),
      ],
    );
  }
}

class _ArenaBackdrop extends StatelessWidget {
  const _ArenaBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF090817), Color(0xFF17132B), Color(0xFF0B1A2C)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0F67D9FF)
      ..strokeWidth = 1;
    const spacing = 34.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

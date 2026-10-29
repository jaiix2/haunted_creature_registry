import 'dart:async';

import 'package:flutter/material.dart';

import 'success_screen.dart';

const _passwordHelpCategory = 'password_help';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

enum _TipStatus { idle, loading, success, error }

class _SignupScreenState extends State<SignupScreen> {
  static const _creatureTypes = [
    'Ghost',
    'Bat',
    'Black Cat',
    'Pumpkin Spirit',
    'Witch',
  ];

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
  final _dateController = TextEditingController();

  DateTime? _birthDate;
  String? _selectedCreatureType;
  bool _obscurePassword = true;
  bool _submitting = false;
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
    _dateController.dispose();
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

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          userName: _nameController.text.trim(),
          creatureType: _selectedCreatureType!,
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _birthDate = picked;
      _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creature Registry'),
        backgroundColor: const Color(0xFF171126),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF100D19),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter the Laboratory',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your creature registration.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF1C1828),
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
                              decoration: _decoration(
                                label: 'Name',
                                icon: Icons.person_outline,
                              ),
                              validator: _validateName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('emailField'),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                label: 'Email',
                                icon: Icons.alternate_email,
                              ),
                              validator: _validateEmail,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('passwordField'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration:
                                  _decoration(
                                    label: 'Password',
                                    icon: Icons.lock,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      key: const Key(
                                        'togglePasswordVisibility',
                                      ),
                                      tooltip: _obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                              validator: _validatePassword,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              key: const Key('creatureDropdown'),
                              initialValue: _selectedCreatureType,
                              dropdownColor: const Color(0xFF252032),
                              style: const TextStyle(color: Colors.white),
                              decoration: _decoration(
                                label: 'Creature type',
                                icon: Icons.pets,
                              ),
                              items: _creatureTypes
                                  .map(
                                    (creature) => DropdownMenuItem(
                                      value: creature,
                                      child: Text(creature),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (creature) {
                                setState(() {
                                  _selectedCreatureType = creature;
                                });
                              },
                              validator: (creature) => creature == null
                                  ? 'Choose a creature type'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('birthDateField'),
                              controller: _dateController,
                              readOnly: true,
                              onTap: _pickBirthDate,
                              decoration: _decoration(
                                label: 'Birth Date',
                                icon: Icons.cake,
                              ),
                              validator: (_) => _birthDate == null
                                  ? 'Pick your birth date'
                                  : null,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              key: const Key('signupButton'),
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Register Creature',
                                      style: TextStyle(fontSize: 18),
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
    );
  }

  InputDecoration _decoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.deepOrangeAccent),
      filled: true,
      fillColor: const Color(0xFF272235),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF514866)),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
                  Text(
                    'Preparing a local preset…',
                    style: TextStyle(color: Colors.white),
                  ),
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
              Text(
                tip,
                style: const TextStyle(height: 1.45, color: Colors.white),
              ),
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
                style: TextStyle(color: Colors.white),
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

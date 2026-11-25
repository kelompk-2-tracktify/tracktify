import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracktify/core/widgets/app_text_field.dart';
import 'package:tracktify/core/widgets/auth_scaffold.dart';
import 'package:tracktify/core/widgets/google_button.dart';
import 'package:tracktify/core/widgets/primary_button.dart';
import 'package:tracktify/features/auth/auth_repository.dart';
import 'package:tracktify/features/auth/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(_email.text.trim(), _password.text);
      // redirect ke /home dilakukan otomatis oleh route guard
    } on AuthFailure catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // redirect ke /home dilakukan otomatis oleh route guard
    } on AuthFailure catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _googleLoading;

    return AuthScaffold(
      title: 'Login',
      subtitle:
      'Enter your email and password to securely access your account.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            AppTextField(
              label: 'Email',
              hint: 'name@kampus.ac.id',
              icon: Icons.mail_outline,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              controller: _password,
              isPassword: true,
              validator: validatePassword,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : () => context.push('/forgot-password'),
                child: const Text('Forgot Password?'),
              ),
            ),
            PrimaryButton(
              label: 'Login',
              loading: _loading,
              onPressed: busy ? null : _submit,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            GoogleButton(
              loading: _googleLoading,
              onPressed: busy ? null : _google,
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: busy ? null : () => context.go('/signup'),
                  child: const Text(
                    'Sign up here',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
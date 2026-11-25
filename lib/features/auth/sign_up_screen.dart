import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracktify/core/widgets/app_text_field.dart';
import 'package:tracktify/core/widgets/auth_scaffold.dart';
import 'package:tracktify/core/widgets/google_button.dart';
import 'package:tracktify/core/widgets/primary_button.dart';
import 'package:tracktify/features/auth/auth_repository.dart';
import 'package:tracktify/features/auth/validators.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      await ref.read(authRepositoryProvider).signUp(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      // Konfirmasi email dimatikan, jadi langsung login dan
      // route guard mengarahkan ke /home
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
      // akun baru dibuat otomatis oleh Supabase, lalu redirect ke /home
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
      title: 'Sign Up',
      subtitle: 'Register with an active email to manage group tasks.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            AppTextField(
              label: 'Full Name',
              hint: 'e.g., Alex Morgan',
              icon: Icons.person_outline,
              controller: _name,
              validator: validateName,
            ),
            const SizedBox(height: 16),
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
              hint: 'Minimum 6 characters',
              icon: Icons.lock_outline,
              controller: _password,
              isPassword: true,
              validator: validatePassword,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm Password',
              hint: 'Re-enter password',
              icon: Icons.lock_reset_outlined,
              controller: _confirm,
              isPassword: true,
              validator: (v) =>
              v != _password.text ? 'Password tidak sama' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create Account',
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
                const Text('Already have an account? '),
                GestureDetector(
                  onTap: busy ? null : () => context.go('/login'),
                  child: const Text(
                    'Login here',
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
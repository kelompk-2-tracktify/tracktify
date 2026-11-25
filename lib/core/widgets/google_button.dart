import 'package:flutter/material.dart';
import 'package:tracktify/app/theme.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  const GoogleButton({
    super.key,
    this.onPressed,
    this.loading = false,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.fieldBorder),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo: taruh di assets/google_logo.png dan daftarkan di pubspec.yaml
            // Kalau belum ada, otomatis tampil huruf "G"
            Image.asset(
              'assets/google_logo.png',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Text('G',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.navy)),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
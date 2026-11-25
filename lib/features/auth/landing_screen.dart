import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracktify/app/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Nanti ganti dengan logo asli: Image.asset('assets/logo.png')
              const Text('Tracktify',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Split group tasks fairly, track member progress, and finish projects on time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white, shape: const StadiumBorder()),
                  onPressed: () => context.go('/signup'),
                  label: const Text('Start Now', style: TextStyle(color: AppColors.navy)),
                  icon: const Icon(Icons.arrow_forward, color: AppColors.navy),
                  iconAlignment: IconAlignment.end,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Login',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
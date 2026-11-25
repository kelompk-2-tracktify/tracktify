import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tracktify/features/auth/landing_screen.dart';
import 'package:tracktify/features/auth/login_screen.dart';
import 'package:tracktify/features/auth/sign_up_screen.dart';

// Layar asli: tambahkan import-nya seiring selesai, ganti _Placeholder
// import '../features/auth/landing_screen.dart';

/// Membuat GoRouter ikut redirect saat status login berubah
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _Placeholder extends StatelessWidget {
  final String name;
  const _Placeholder(this.name);
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(name)));
}

const _publicRoutes = {
  '/landing', '/login', '/signup', '/forgot-password', '/otp', '/set-password',
};
const _authOnlyEntry = {'/landing', '/login', '/signup'};

final routerProvider = Provider<GoRouter>((ref) {
  final auth = Supabase.instance.client.auth;
  final refresh = GoRouterRefreshStream(auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/landing',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentSession != null;
      final loc = state.matchedLocation;
      if (!loggedIn && !_publicRoutes.contains(loc)) return '/landing';
      if (loggedIn && _authOnlyEntry.contains(loc)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/landing', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const _Placeholder('Forgot Password')),
      GoRoute(path: '/otp', builder: (_, s) => _Placeholder('OTP ${s.extra ?? ''}')),
      GoRoute(path: '/set-password', builder: (_, __) => const _Placeholder('Set New Password')),

      // Layar dengan bottom navigation: Home dan Profile
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const _Placeholder('Home / Task List')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const _Placeholder('Profile')),
          ]),
        ],
      ),

      // Layar penuh (di atas bottom nav)
      GoRoute(path: '/join', builder: (_, __) => const _Placeholder('Join Task')),
      // /manage-task = buat baru, /manage-task?id=xxx = edit
      GoRoute(
        path: '/manage-task',
        builder: (_, s) => _Placeholder('Manage Task ${s.uri.queryParameters['id'] ?? ''}'),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (_, s) => _Placeholder('Project ${s.pathParameters['id']}'),
      ),
    ],
  );
});

/// Bottom navigation: Home | Add | Profile
class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    // shell.currentIndex: 0 = home, 1 = profile  ->  UI index: 0, 2
    final uiIndex = shell.currentIndex == 0 ? 0 : 2;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: uiIndex,
        onDestinationSelected: (i) {
          if (i == 1) {
            context.push('/manage-task');
          } else {
            shell.goBranch(i == 0 ? 0 : 1);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
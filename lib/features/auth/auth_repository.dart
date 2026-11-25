import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

const webClientId = '664913986781-fm52u7hkf17fu9oh114duhjshsfdea2g.apps.googleusercontent.com';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName}, // dibaca trigger handle_new_user
      );
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (_) {
      throw AuthFailure('Tidak bisa terhubung. Periksa koneksi internet.');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (_) {
      throw AuthFailure('Tidak bisa terhubung. Periksa koneksi internet.');
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(serverClientId: webClientId);
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw AuthFailure('Token Google tidak ditemukan');
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (_) {
      throw AuthFailure('Login Google dibatalkan atau gagal');
    }
  }

  String _translate(AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return 'Email atau password salah';
    if (m.contains('already registered')) return 'Email sudah terdaftar';
    if (m.contains('rate limit')) return 'Terlalu banyak percobaan, coba lagi nanti';
    if (m.contains('password')) return 'Password tidak memenuhi syarat';
    return e.message;
  }
}

final authRepositoryProvider =
Provider((ref) => AuthRepository(Supabase.instance.client));

final currentUserProvider = StreamProvider<User?>((ref) async* {
  final client = Supabase.instance.client;
  yield client.auth.currentUser;
  yield* client.auth.onAuthStateChange.map((s) => s.session?.user);
});
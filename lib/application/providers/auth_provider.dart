import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth の認証状態ストリーム。
/// React の `useContext(AuthContext)` に相当するが、
/// Riverpod は Provider ツリーに縛られず任意の場所で `ref.watch` できる点で優れている。
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ---------------------------------------------------------------------------
// Auth Actions (Notifier)
// ---------------------------------------------------------------------------

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() async {
    // TODO: google_sign_in パッケージ追加後に実装
    // GoogleSignIn → Firebase credential → signInWithCredential
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithProvider(googleProvider);
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final appleProvider = AppleAuthProvider();
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Register a new user with email and password
  /// Returns the User object on success, null on failure
  Future<User?> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  /// Login an existing user with email and password
  /// Returns the User object on success, null on failure
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Handle exception silently or rethrow if needed
    }
  }

  /// Stream of authentication state changes
  /// Returns a stream that emits the current User when auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}

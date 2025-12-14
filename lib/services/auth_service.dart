import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_service.dart';

/// Authentication service for Firebase Auth operations
///
/// Handles user authentication including anonymous sign-in,
/// email/password, and social sign-in methods.
class AuthService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current authenticated user, if any
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in
  bool get isSignedIn => currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (includes profile updates)
  Stream<User?> get userChanges => _auth.userChanges();

  @override
  Future<void> onInitialize() async {
    // Firebase Auth is automatically initialized with Firebase.initializeApp()
    // This method can be used for any additional setup
  }

  @override
  Future<void> onDispose() async {
    // No cleanup needed for Firebase Auth
  }

  /// Sign in anonymously
  ///
  /// Creates an anonymous user account that can later be upgraded
  /// to a permanent account.
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Create a new account with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Delete the current user's account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw StateError('No user signed in');
    }
    await user.delete();
  }

  /// Update the current user's display name
  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('No user signed in');
    }
    await user.updateDisplayName(displayName);
  }

  /// Map Firebase Auth exceptions to more readable errors
  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      default:
        return Exception(e.message ?? 'Authentication failed.');
    }
  }
}

/// Provider for AuthService
/// Can be overridden in tests with a mock
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

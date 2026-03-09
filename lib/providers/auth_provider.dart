import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService {
    _authSub = _authService.authStateChanges().listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  bool isLoading = false;
  String? errorMessage;

  User? _firebaseUser;
  UserProfile? _profile;

  StreamSubscription<User?>? _authSub;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get profile => _profile;

  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    if (user != null) {
      _loadUserProfile(user.uid);
    } else {
      _profile = null;
      isLoading = false;
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final profile = await _firestoreService.getUserProfile(uid);
      _profile = profile;
    } catch (_) {
      // Swallow errors here; UI can still function with minimal user info.
    } finally {
      notifyListeners();
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final profile = UserProfile(
          uid: user.uid,
          email: user.email ?? email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createOrUpdateUserProfile(profile);
        _profile = profile;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? e.code;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? e.code;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      _firebaseUser = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      errorMessage ??= e.toString();
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification() {
    return _authService.sendEmailVerification();
  }

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _firebaseUser = null;
      _profile = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}


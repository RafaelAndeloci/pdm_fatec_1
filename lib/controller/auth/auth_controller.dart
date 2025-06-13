import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:pdm_fatec_1/model/auth_model.dart';
import 'package:pdm_fatec_1/services/auth_service.dart';
import 'package:pdm_fatec_1/services/storage_service.dart';

class AuthController with ChangeNotifier {
  static const String _storageKey = 'current_user';

  final StorageService _storageService;
  final AuthService _authService;

  firebase_auth.User? _firebaseUser;
  User _currentUser = User.guest();
  String? _error;
  bool _isLoading = false;

  AuthController(this._storageService, this._authService) {
    _init();
  }

  User get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser.isAuthenticated;
  String? get error => _error;
  bool get isLoading => _isLoading;

  void _init() {
    _authService.authStateChanges.listen((firebase_auth.User? user) {
      _firebaseUser = user;
      if (user != null) {
        _currentUser = User(
          id: user.uid,
          name: user.displayName ?? 'Usuário',
          email: user.email ?? '',
          isAuthenticated: true,
        );
      } else {
        _currentUser = User.guest();
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );
      await userCredential.user?.updateDisplayName(name);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _currentUser = User.guest();
      await _storageService.removeData(_storageKey);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    return _firebaseUser != null;
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
